#!/usr/bin/env ruby

require 'roo'
require 'caxlsx'
require 'pry'

FACTURAS = { "FACTURA A" => "1 - Factura A", "N/CA A" => "3 - Nota de Crédito A", "FACTURA B" => "6 - Factura B", "N/CB B" => "8 - Nota de Crédito B", "FACTURA C" => "11 - Factura C", "N/CC C" => "3 - Nota de Crédito C" }

def parse(file1, file2)
  begin
    holistor = []
    afip = []

    xlsx1 = Roo::Spreadsheet.open(file1)
    xlsx1.each_row_streaming(offset: 1) do |row|
      holistor << row
    end

    holistor = holistor[5..(holistor.size - 6)]
    holistor.reject! { |row| row.size < 10 }

    xlsx2 = Roo::Spreadsheet.open(file2)
    xlsx2.each_row_streaming(offset: 1) do |row|
      afip << row
    end

    afip = afip[1..(afip.size - 1)]

    [holistor, afip]

  rescue e
    puts "Error al procesar los archivos excel: #{e}"
  end
end

class Validator
  Validation = Struct.new(:value, :description)
  attr_reader :row, :destination

  def initialize(row, destination)
    @row = row
    @destination = destination
  end

  def call
    [client_identifier, client_name, invoice_number, invoice_date, invoice_type, invoice_amount, invoice_validated, invoice_description
    ]
  end

  private

  def invoice_validated
    validation.value
  end

  def invoice_description
    validation.description
  end

  def validation
    @validation ||= build_validation
  end
end

class HolistorValidator < Validator
  def client_identifier
    row[5].value
  end

  def client_name
    row[4].value
  end

  def invoice_date
    row[0].value
  end

  def invoice_number
    row[3].value
  end

  def invoice_type
    "#{row[1].value} #{row[2].value}"
  end

  def invoice_amount
    row[8].value.abs
  end

  def build_validation
    return Validation.new(false, "Factura no encontrada en AFIP") if target.nil?
    return Validation.new(false, "Factura C") if row[2].value == "C"
    return Validation.new(false, "Error en fechas") if target[0].value != invoice_date
    return Validation.new(false, "Error en monto") unless target[10].value.between?(invoice_amount - 1, invoice_amount + 1)

    Validation.new(true, nil)
  end

  def target
    @target ||= destination.find do |destination_row|
      punto_venta, comprobante = row[3].value.split("-").map(&:to_i)

      punto_venta == destination_row[2].value && comprobante == destination_row[3].value && FACTURAS[invoice_type] == destination_row[1].value
    end
  end
end

class AfipValidator < Validator
  def valid?
    !validation.nil?
  end

  private

  def client_identifier
    row[5].value.to_s.sub(/\A(\d{2})(\d{8})(\d{1})\z/, '\1-\2-\3')
  end

  def client_name
    row[6].value
  end

  def invoice_date
    row[0].value
  end

  def invoice_number
    "#{"%04d" % row[2].value}-#{"%08d" % row[3].value}"
  end

  def invoice_type
    FACTURAS.key(row[1].value)
  end

  def invoice_amount
    row[10]&.value&.abs
  end

  def build_validation
    return Validation.new(false, "Factura no encontrada en HOLISTOR") if target.nil?
    return Validation.new(false, "Factura C HOLISTOR") if row[1].value.include?('Factura C') || target[2].value == "C"

    Validation.new(true, nil)
  end

  def target
    @target ||= destination.find do |destination_row|
      punto_venta, comprobante = destination_row[3].value.split("-").map(&:to_i)

      type = "#{destination_row[1].value} #{destination_row[2].value}"
      punto_venta == row[2].value && comprobante == row[3].value && FACTURAS[type] == row[1].value
    end
  end
end

def crear_archivo_resultante
  Axlsx::Package.new do |p|
    p.workbook.add_worksheet(name: "Resultado") do |sheet|
      sheet.add_row ["cuil/dni", "nombre", "nroFactura", "fecha", "tipo", "monto", "validada", "descripcion"]
      @holistor.each do |row|
        sheet.add_row [*HolistorValidator.new(row, @afip).call]
      end

      @afip.each do |row|
        sheet.add_row [*AfipValidator.new(row, @holistor).call]
      end
    end
    p.serialize("control_iva.xlsx")
  end
end

archivo1, archivo2 = ARGV[0], ARGV[1]
@holistor, @afip = parse(archivo1, archivo2)
crear_archivo_resultante

puts "Archivo resultante creado correctamente."