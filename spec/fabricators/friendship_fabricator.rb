# frozen_string_literal: true

Fabricator(:friendship) do
  user_1_id { Fabricate(:user).id }
  user_2_id { Fabricate(:user).id }
end
