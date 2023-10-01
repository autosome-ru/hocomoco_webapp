require 'bioinform'
require_relative 'dipm'

module ModelKind
  def self.get(mode)
    case mode
    when Mono
      mode
    when /^mono$/i
      @mono ||= Mono.new
    else
      raise "Unknown mode `#{mode.inspect}`; should be `:mono` or `:di`"
    end
  end

  class Mono
    def arity_type; 'mono'; end
    def pwm_extension; 'pwm'; end
    def pcm_extension; 'pcm'; end
    def pfm_extension; 'pfm'; end
    def to_s; 'mono'; end
    def read_pcm(path_to_pcm)
      parser = Bioinform::MatrixParser.new(fix_nucleotides_number: 4, nucleotides_in: :columns)
      infos = parser.parse(File.read(path_to_pcm))
      name = infos[:name] || File.basename(path_to_pcm, ".#{pcm_extension}")
      Bioinform::MotifModel::PCM.new(infos[:matrix]).named(name)
    end
    def read_pwm(path_to_pwm)
      parser = Bioinform::MatrixParser.new(fix_nucleotides_number: 4, nucleotides_in: :columns)
      infos = parser.parse(File.read(path_to_pwm))
      name = infos[:name] || File.basename(path_to_pwm, ".#{pwm_extension}")
      Bioinform::MotifModel::PWM.new(infos[:matrix]).named(name)
    end
    def read_pfm(path_to_pfm)
      parser = Bioinform::MatrixParser.new(fix_nucleotides_number: 4, nucleotides_in: :columns)
      infos = parser.parse(File.read(path_to_pfm))
      name = infos[:name] || File.basename(path_to_pfm, ".#{pfm_extension}")
      Bioinform::MotifModel::PPM.new(infos[:matrix]).named(name)
    end
  end
end
