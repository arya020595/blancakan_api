# frozen_string_literal: true

module PayoutMethods
  module AccountMasking
    extend ActiveSupport::Concern

    # Instance methods for account number masking
    def masked_account_no
      mask_account_number(bank_account_no)
    end

    def masked_account_number(account_number, visible_digits: 4)
      return '' if account_number.blank?
      
      account_no = account_number.to_s
      if account_no.length <= visible_digits
        '*' * account_no.length
      else
        '*' * (account_no.length - visible_digits) + account_no.last(visible_digits)
      end
    end

    def partially_masked_account_no(visible_start: 2, visible_end: 4)
      return '' if bank_account_no.blank?
      
      account_no = bank_account_no.to_s
      total_length = account_no.length
      
      if total_length <= (visible_start + visible_end)
        masked_account_no
      else
        start_part = account_no.first(visible_start)
        end_part = account_no.last(visible_end)
        middle_length = total_length - visible_start - visible_end
        middle_mask = '*' * middle_length
        
        "#{start_part}#{middle_mask}#{end_part}"
      end
    end
  end
end
