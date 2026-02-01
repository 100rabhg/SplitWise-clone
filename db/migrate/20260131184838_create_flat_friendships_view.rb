class CreateFlatFriendshipsView < ActiveRecord::Migration[6.1]
  def up
    puts "CREATING flat_friendships VIEW"

    execute <<-SQL
      CREATE OR REPLACE VIEW flat_friendships AS
      SELECT id, user_1_id AS user_id, user_2_id AS friend_id, deleted_at FROM friendships
      UNION
      SELECT id, user_2_id AS user_id, user_1_id AS friend_id, deleted_at FROM friendships;
    SQL

    say "CREATED flat_friendships VIEW"
  end

  def down
    execute "DROP VIEW IF EXISTS flat_friendships"
  end
end
