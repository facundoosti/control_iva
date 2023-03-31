class HolistorValidator < Validator
  FIELD_DATE = 0
  FIELD_INVOICE_TYPE = 1
  FIELD_TYPE = 2
  FIELD_INVOICE = 3
  FIELD_INDETIFIER = 5
  FIELD_NAME = 4
  FIELD_IVA = 8

  def client_identifier
    row[FIELD_INDETIFIER].value
  end

  def client_name
    row[FIELD_NAME].value
  end

  def invoice_date
    row[FIELD_DATE].value
  end

  def invoice_number
    row[FIELD_INVOICE].value
  end

  def invoice_type
    "#{row[FIELD_INVOICE_TYPE].value} #{row[FIELD_TYPE].value}"
  end

  def invoice_iva
    row[FIELD_IVA].value.abs
  end

  def build_validation
    return Validation.new(false, "Factura no encontrada en AFIP") if target.nil?
    return Validation.new(false, "Factura C") if row[FIELD_TYPE].value == "C"
    return Validation.new(false, "Error en fechas") if target[AfipValidator::FIELD_DATE].value != invoice_date
    return Validation.new(false, "Error en monto") unless target[AfipValidator::FIELD_IVA].value.between?(invoice_iva - 1, invoice_iva + 1)

    Validation.new(true, nil)
  end

  def target
    @target ||= destination.find do |destination_row|
      punto_venta, comprobante = row[FIELD_INVOICE].value.split("-").map(&:to_i)

      punto_venta == destination_row[AfipValidator::FIELD_SALE_POINT].value &&
        comprobante == destination_row[AfipValidator::FIELD_INVOICE].value &&
        FACTURAS[invoice_type] == destination_row[AfipValidator::FIELD_TYPE].value
    end
  end
end