# frozen_string_literal: true

Fabricator(:friendship_balance) do
  friendship { Fabricate(:friendship) }
  balance { rand(1..100) }
  owes_to { Fabricate(:user) }
end
