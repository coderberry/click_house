# frozen_string_literal: true

# rubocop:disable Metrics/ParameterLists
module ClickHouse
  module Extend
    module ConnectionAltering
      def add_column(table, name, type, default: nil, if_not_exists: false, after: nil, cluster: nil)
        sql = 'ADD COLUMN %<exists>s %<name>s %<type>s %<default>s %<after>s'

        pattern = {
          name: name,
          exists: Util::Statement.ensure(if_not_exists, 'IF NOT EXISTS'),
          type: type,
          default: Util::Statement.ensure(default, "DEFAULT #{default}"),
          after: Util::Statement.ensure(after, "AFTER #{after}")
        }

        alter_table(table, format(sql, pattern), cluster: cluster)
      end

      def drop_column(table, name, if_exists: false, cluster: nil)
        sql = 'DROP COLUMN %<exists>s %<name>s'

        pattern = {
          name: name,
          exists: Util::Statement.ensure(if_exists, 'IF EXISTS')
        }

        alter_table(table, format(sql, pattern), cluster: cluster)
      end

      def clear_column(table, name, partition:, if_exists: false, cluster: nil)
        sql = 'CLEAR COLUMN %<exists>s %<name>s %<partition>s'

        pattern = {
          name: name,
          exists: Util::Statement.ensure(if_exists, 'IF EXISTS'),
          partition: "IN PARTITION #{partition}"
        }

        alter_table(table, format(sql, pattern), cluster: cluster)
      end

      def modify_column(table, name, type: nil, default: nil, if_exists: false, cluster: nil)
        sql = 'MODIFY COLUMN %<exists>s %<name>s %<type>s %<default>s'

        pattern = {
          name: name,
          type: type,
          exists: Util::Statement.ensure(if_exists, 'IF EXISTS'),
          default: Util::Statement.ensure(default, "DEFAULT #{default}")
        }

        alter_table(table, format(sql, pattern), cluster: cluster)
      end

      def alter_table(name, sql = nil, cluster: nil)
        template = 'ALTER TABLE %<name>s %<cluster>s %<sql>s'
        sql = yield(sql) if sql.nil?

        pattern = {
          name: name,
          sql: sql,
          cluster: Util::Statement.ensure(cluster, "ON CLUSTER #{cluster}"),
        }

        execute(format(template, pattern)).success?
      end
    end
  end
end
# rubocop:enable Metrics/ParameterLists
