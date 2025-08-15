class AddTokenDigestToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :token_digest, :string
  end
end
