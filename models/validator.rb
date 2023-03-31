class Validator
  Validation = Struct.new(:value, :description)
  attr_reader :row, :destination

  def initialize(row, destination)
    @row = row
    @destination = destination
  end

  def call
    [
      client_identifier,
      client_name,
      invoice_number,
      invoice_date,
      invoice_type,
      invoice_iva,
      invoice_validated,
      invoice_description
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
