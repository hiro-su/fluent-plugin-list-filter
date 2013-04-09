require 'yaml'

module Fluent
  class ListFilterOutput < Output
    Plugin.register_output 'list_filter', self

    config_param :path, :string, default: nil
    config_param :tag, :string, default: "'filtered.' + tag"
    config_param :filter_type, :string, default: "allow" #or "deny"

    def configure conf
      super
      @list = YAML.load_file @path
      @keys = @list.keys
      @filter = @filter_type == "deny" ? "!=" : "=="
    end

    def emit tag, es, chain
      emit = lambda {|new_tag, stream| Engine.emit_stream new_tag, stream }
      es.each do |time, record|
        do_list_filter @list, record do
          emit.call eval(@tag), es
        end
      end
      chain.next
    rescue => ex
      $log.error ex
      raise ex
    end

    def do_list_filter list, record
      counter = 0
      list.each do |key, value_arr|
        value_arr.each do |value|
          if record[key].__send__(@filter, value)
            counter += 1
            case @filter_type
            when "allow"
              if counter == @keys.size
                yield
              end
            when "deny"
              if counter == list[key].size + @keys.size - 1
                yield
              elsif @keys.size == 1
                yield
              end
            end
          end
        end
      end
    rescue => ex
      $log.error ex
      raise ex
    end
  end
end
