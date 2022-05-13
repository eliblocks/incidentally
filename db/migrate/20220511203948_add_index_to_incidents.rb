class AddIndexToIncidents < ActiveRecord::Migration[7.0]
  def change
    add_index :incidents, :slack_channel_id
  end
end
