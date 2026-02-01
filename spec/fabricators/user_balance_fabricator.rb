# frozen_string_literal: true

Fabricator(:user_balance) do
  user { Fabricate(:user) }
  total_due { 0 }
  total_owed { 0 }
  net_balance { 0 }
end
