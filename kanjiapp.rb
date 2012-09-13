# encoding: utf-8
require 'camping'
require 'haml'
require 'nokogiri'
require 'active_support/json'

Camping.goes :Kanji

module Kanji
  module Kanji::Controllers

    class Index
      def get
        if(@input.k != nil && @input.k != '')
          @kanji = @input.k
          @dic = open_dic
          @meanings = meanings(@dic, @kanji)
          @on_readings = on_readings(@dic, @kanji)
          @kun_readings = kun_readings(@dic, @kanji)
          @render_result = true
        else
          @render_result = false
        end
        render :index
      end

    end

    class Json < R '/([^/]+).json'
      def get(kanji)
        @kanji = kanji
        @dic = open_dic
        @meanings = meanings(@dic, @kanji)
        @on_readings = on_readings(@dic, @kanji)
        @kun_readings = kun_readings(@dic, @kanji)

        @headers['Content-Type'] = "application/json"
        h = {:kanji => {:kanji => @kanji, :meanings => @meanings, :on_readings => @on_readings, :kun_readings => @kun_readings}}
        h.to_json
      end
    end

    class Style < R '/style\.css'
      STYLE = File.read('public/style.css')

      def get
        @headers['Content-Type'] = 'text/css; charset=utf-8'
        STYLE
      end
    end

  end #Controllers

  module Helpers
      def open_dic
        f = File.open('kanjidic2.xml')
        kanjidic = Nokogiri::XML(f)
        f.close
        return kanjidic
      end

      def meanings(d, k)
        meanings = d.xpath("//literal[text()='"+k+"']/../reading_meaning/rmgroup/meaning[not(@m_lang)]").collect(&:text)
        return meanings
      end

      def on_readings(d, k)
        on_readings = d.xpath("//literal[text()='"+k+"']/../reading_meaning/rmgroup/reading[@r_type='ja_on']").collect(&:text)
        return on_readings
      end

      def kun_readings(d, k)
        kun_readings = d.xpath("//literal[text()='"+k+"']/../reading_meaning/rmgroup/reading[@r_type='ja_kun']").collect(&:text)
        return kun_readings
      end
  end #Helpers
end
