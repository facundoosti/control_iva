# frozen_string_literal: true

class HolistorValidator < Validator
  def build_validation
    return Validation.new(false, 'Diferencia de tipos') if target && target.type != invoice.type
    return Validation.new(false, 'Factura no encontrada en AFIP') if target.nil?
    return Validation.new(false, 'Factura C') if invoice.type == 'Factura C'
    return Validation.new(false, 'Error en fechas') if target.date != invoice.date
    return Validation.new(false, 'Error en monto') unless target.iva.between?(invoice.iva - 1, invoice.iva + 1)

    Validation.new(true, nil)
  end
end
