class CreateAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :answers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :question
      t.string :selected
      t.boolean :correct

      t.timestamps
    end
  end
end
