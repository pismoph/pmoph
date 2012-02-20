module CompositePrimaryKeys
  module ActiveRecord
    module FinderMethods
      module InstanceMethods
        def construct_limited_ids_condition(relation)
          orders = relation.order_values.join(", ")

          # CPK
          # values = @klass.connection.distinct("#{@klass.connection.quote_table_name @klass.table_name}.#{@klass.primary_key}", orders)
          keys = @klass.primary_keys.map do |key|
            "#{@klass.connection.quote_table_name @klass.table_name}.#{key}"
          end

          values = @klass.connection.distinct(keys.join(', '), orders)

          ids_array = relation.select(values).collect {|row| row[@klass.primary_key]}

          # CPK
          # ids_array.empty? ? raise(ThrowResult) : primary_key.in(ids_array)

          # OR together each and expression (key=value and key=value) that matches an id set
          # since we only need to match 0 or more records
          or_expressions = ids_array.map do |id_set|
            # AND together "key=value" exprssios to match each id set
            and_expressions = [self.primary_keys, id_set].transpose.map do |key, id|
              table[key].eq(id)
            end

            # Merge all the ands together
            first = and_expressions.shift
            Arel::Nodes::Grouping.new(and_expressions.inject(first) do |memo, expr|
                Arel::Nodes::And.new(memo, expr)
            end)
          end

          first = or_expressions.shift
          Arel::Nodes::Grouping.new(or_expressions.inject(first) do |memo, expr|
              Arel::Nodes::Or.new(memo, expr)
          end)
        end
        
        def exists?(id = nil)
          # ID can be:
          #   Array - ['department_id = ? and location_id = ?', 1, 1]
          #   Array -> [1,2]
          #   CompositeKeys -> [1,2]

          id = id.id if ::ActiveRecord::Base === id

          case id
          # CPK
          when CompositePrimaryKeys::CompositeKeys
            relation = select(primary_keys).limit(1)
            relation = relation.where(ids_predicate(id)) if id
            relation.first ? true : false
          when Array
            # CPK
            if id.first.is_a?(String) and id.first.match(/\?/)
              where(id).exists?
            else
              exists?(id.to_composite_keys)
            end
          when Hash
            where(id).exists?
          else
             # CPK
             #relation = select(primary_key).limit(1)
             #relation = relation.where(primary_key.eq(id)) if id
             relation = select(primary_keys).limit(1)
             relation = relation.where(ids_predicate(id)) if id

            relation.first ? true : false
          end
        end

        def find_with_ids(*ids, &block)
          return to_a.find(&block) if block_given?

          ids = ids.first if ids.last == nil
          ids = [ids.to_composite_ids] if not ids.first.kind_of?(Array)

          ids.each do |id_set|
            unless id_set.is_a?(Array)
              raise "Ids must be in an Array, instead received: #{id_set.inspect}"
            end
            unless id_set.length == @klass.primary_keys.length
              raise "#{id_set.inspect}: Incorrect number of primary keys for #{@klass.name}: #{@klass.primary_keys.inspect}"
            end
          end

          new_relation = clone
          ids.each do |id_set|
            [@klass.primary_keys, id_set].transpose.map do |key, id|
              new_relation = new_relation.where(key => id)
            end
          end

          result = new_relation.to_a

          if result.size == ids.size
            ids.size == 1 ? result[0] : result
          else
            raise ::ActiveRecord::RecordNotFound, "Couldn't find all #{@klass.name} with IDs (#{ids.inspect})"
          end
        end
      end
    end
  end
end
