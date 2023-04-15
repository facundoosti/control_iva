# frozen_string_literal: true

class AfipValidator < Validator
  private

  def build_validation
    return Validation.new(false, 'Diferencia de tipos') if target && target.type != invoice.type
    return Validation.new(false, 'Factura no encontrada en HOLISTOR') if target.nil?

    Validation.new(true, nil)
  end
end
