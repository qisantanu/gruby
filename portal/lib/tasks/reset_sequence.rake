# frozen_string_literal: true

namespace :db do
  desc 'reset the sequnce of a table'
  task reset_sequnce: :environment do
    # TODO: Supriya needs to pass the table name as an argument
    my_table = 'obu_details'
    my_table_sequence = 'obu_details_id_seq'
    sql = "SELECT MAX(id) FROM #{my_table};"
    result = ApplicationRecord.connection.exec_query(sql).rows.flatten.first
    sql = "SELECT nextval('#{my_table_sequence}');"
    sequence_result = ApplicationRecord.connection.exec_query(sql).rows.flatten.first

    if sequence_result <= result
      sql = <<-SQL
        SELECT setval(#{my_table_sequence}, COALESCE((SELECT MAX(id)+1 FROM #{my_table}), 1), false);
      SQL

      ApplicationRecord.connection.exec_query(sql)
    end
  end
end
