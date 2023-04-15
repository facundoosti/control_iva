#!/usr/bin/env ruby
# frozen_string_literal: true

require 'roo'
require 'caxlsx'
require 'pry'
require './models/validator'
require './models/holistor_validator'
require './models/afip_validator'

FACTURAS = { 'FACTURA A' => '1 - Factura A', 'N/CA A' => '3 - Nota de Crédito A', 'F.C C' => '11 - Factura C',
             'FACTURA B' => '6 - Factura B', 'N/CB B' => '8 - Nota de Crédito B', 'FACTURA C' => '11 - Factura C', 'N/CC C' => '3 - Nota de Crédito C' }.freeze
HEADERS = ['cuil/dni', 'nombre', 'puntoDeVenta', 'nroFactura', 'fecha', 'tipo', 'monto', 'validada', 'descripcion',
           'origen'].freeze

Invoice = Struct.new(:date, :type, :sale_point, :number, :identifier, :name, :iva)

def parse_holistor(file)
  xlsx = Roo::Spreadsheet.open(file)

  [].tap do |invoices|
    xlsx.each_row_streaming do |row|
      begin
        Date.strptime(row[0].value, '%d/%m/%Y')
      rescue StandardError
        next
      end

      invoices << Invoice.new(row[0].value, "#{row[1].value} #{row[2].value}", row[3].value.split('-')[0].to_i,
                              row[3].value.split('-')[1].to_i, row[5].value, row[4].value, row[8].value.abs)
    end
  end
end

def parse_afip(file)
  xlsx = Roo::Spreadsheet.open(file)

  [].tap do |invoices|
    xlsx.parse(date: 'Fecha', type: 'Tipo', sale_point: 'Punto de Venta', invoice: 'Número Desde',
               identifier: 'Nro. Doc. Emisor', name: 'Denominación Emisor', iva: 'IVA').each do |row|
      row[:type] = FACTURAS.key row[:type]
      row[:identifier] = row[:identifier].to_s.sub(/\A(\d{2})(\d{8})(\d{1})\z/, '\1-\2-\3')
      row[:iva] = row[:iva].to_f
      invoices << Invoice.new(*row.values)
    end
  end
end

def build_row(invoice, validator, origin)
  [invoice.identifier, invoice.name, invoice.sale_point, invoice.number, invoice.date, invoice.type, invoice.iva,
   validator.valid, validator.description, origin]
end

def create_file
  Axlsx::Package.new do |p|
    p.workbook.add_worksheet(name: 'Resultado') do |sheet|
      sheet.add_row(HEADERS)
      @holistor.each do |invoice|
        validator = HolistorValidator.new(invoice, @afip)
        new_row = build_row(invoice, validator, 'holistor')
        sheet.add_row(new_row)
      end

      @afip.each do |invoice|
        validator = AfipValidator.new(invoice, @holistor)
        new_row = build_row(invoice, validator, 'afip')
        sheet.add_row(new_row)
      end
    end
    p.serialize('control_iva.xlsx')
  end
end

archivo1 = ARGV[0]
archivo2 = ARGV[1]
begin
  @holistor = parse_holistor(archivo1)
  @afip = parse_afip(archivo2)
rescue e
  puts "Error al procesar los archivos excel: #{e}"
end
create_file

puts 'Archivo resultante creado correctamente.'
