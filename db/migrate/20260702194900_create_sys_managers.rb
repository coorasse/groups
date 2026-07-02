class CreateSysManagers < ActiveRecord::Migration[8.1]
  def change
    create_table :sys_managers do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :sys_managers, :email_address, unique: true
  end
end
