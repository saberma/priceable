require "priceable/version"

module Priceable
  SUFFIXES = ["_in_cents", "_in_pennies", "_as_integer"]
  def priceable(*price_fields)
    price_fields.each do |price_field|
      suffix = SUFFIXES.detect { |suffix| self.attribute_method? "#{price_field}#{suffix}".to_sym }
      #raise ArgumentError, "Unable to find valid database field for `#{price_field}'" unless suffix
      next unless suffix # raise error will cause the migration break.
      define_method price_field do
        unless send("#{price_field}#{suffix}".to_sym).nil?
          send("#{price_field}#{suffix}".to_sym) / 100.0
        else
          0.0
        end
      end
      define_method "#{price_field}=".to_sym do |new_price|
        send("#{price_field}#{suffix}=".to_sym, (new_price.to_f * 100).round)
      end
    end

    unless Rails::VERSION::MAJOR == 4 && !defined?(ProtectedAttributes)
      if self._accessible_attributes?
        attr_accessible *price_fields
      end
    end

  end
end

ActiveRecord::Base.send(:extend, Priceable)
