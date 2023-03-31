#!/usr/bin/env ruby

require 'roo'
require 'caxlsx'
require 'pry'
require './models/validator'
require './models/holistor_validator'
require './models/afip_validator'

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