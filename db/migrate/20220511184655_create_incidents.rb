class CreateIncidents < ActiveRecord::Migration[7.0]
  def change
    create_table :incidents do |t|
      t.string :title
      t.text :description
      t.string :severity
      t.string :slack_channel_id
      t.string :creator_name
      t.string :slack_creator_id
      t.datetime :resolved_at

      t.timestamps
    end
  end
end
