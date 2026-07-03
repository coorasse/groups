class AddMessageTemplateToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :message_template, :text
  end
end
