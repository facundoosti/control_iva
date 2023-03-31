class AfipValidator < Validator
  FIELD_DATE = 0
  FIELD_TYPE = 1
  FIELD_SALE_POINT = 2
  FIELD_INVOICE = 3
  FIELD_INDETIFIER = 6
  FIELD_NAME = 7
  FIELD_IVA = 13

  def valid?
    !validation.nil?
  end

  private

  def client_identifier
    row[FIELD_INDETIFIER].value.to_s.sub(/\A(\d{2})(\d{8})(\d{1})\z/, '\1-\2-\3')
  end

  def client_name
    row[FIELD_NAME].value
  end

  def invoice_date
    row[FIELD_DATE].value
  end

  def invoice_number
    "#{"%04d" % row[FIELD_SALE_POINT].value}-#{"%08d" % row[FIELD_INVOICE].value}"
  end

  def invoice_type
    FACTURAS.key(row[FIELD_TYPE].value)
  end

  def invoice_iva
    row[FIELD_IVA]&.value&.abs
  end

  def build_validation
    return Validation.new(false, "Factura no encontrada en HOLISTOR") if target.nil?
    return Validation.new(false, "Factura C HOLISTOR") if row[FIELD_TYPE].value.include?('Factura C') || target[HolistorValidator::FIELD_TYPE].value == "C"

    Validation.new(true, nil)
  end

  def target
    @target ||= destination.find do |destination_row|
      punto_venta, comprobante = destination_row[HolistorValidator::FIELD_INVOICE].value.split("-").map(&:to_i)
      type = "#{destination_row[HolistorValidator::FIELD_INVOICE_TYPE].value} #{destination_row[HolistorValidator::FIELD_TYPE].value}"

      punto_venta == row[FIELD_SALE_POINT].value &&
        comprobante == row[FIELD_INVOICE].value &&
        FACTURAS[type] == row[FIELD_TYPE].value
    end
  end
end