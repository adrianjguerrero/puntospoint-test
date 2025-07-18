class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs do |t|
      t.timestamps
      t.string :action, null: false
      t.references :user, null: false, foreign_key: true
      t.references :auditable, polymorphic: true, null: false
      t.json :previous_data
      t.json :new_data
    end
  end
end
