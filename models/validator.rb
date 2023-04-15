# frozen_string_literal: true

class Validator
  Validation = Struct.new(:value, :description)
  attr_reader :invoice, :destination

  def initialize(invoice, destination)
    @invoice = invoice
    @destination = destination
  end

  def valid
    validation.value
  end

  def description
    validation.description
  end

  private

  def validation
    @validation ||= build_validation
  end

  def target
    @target ||= destination.find do |other_invoice|
      invoice.number == other_invoice.number &&
        invoice.sale_point == other_invoice.sale_point
    end
  end
end
