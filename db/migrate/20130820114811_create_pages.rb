class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :name
      t.integer :test_unipages

      t.timestamps
    end
  end
end
