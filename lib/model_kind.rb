require 'bioinform'
require_relative 'dipm'

module ModelKind
  def self.get(mode)
    case mode
    when Mono, Di
      mode
    when /^mono$/i
      @mono ||= Mono.new
    when /^di$/i
      @di ||= Di.new
    else
      raise "Unknown mode `#{mode.inspect}`; should be `:mono` or `:di`"
    end
  end

  class Mono
    def arity_type; 'mono'; end
    def pwm_extension; 'pwm'; end
    def pcm_extension; 'pcm'; end
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
  end

  class Di
    def arity_type; 'di'; end
    def pwm_extension; 'dpwm'; end
    def pcm_extension; 'dpcm'; end
    def to_s; 'di'; end
    def read_pcm(path_to_pcm)
      parser = Bioinform::MatrixParser.new(fix_nucleotides_number: 16, nucleotides_in: :columns)
      infos = parser.parse(File.read(path_to_pcm))
      name = infos[:name] || File.basename(path_to_pcm, ".#{pcm_extension}")
      Bioinform::MotifModel::DiPCM.new(infos[:matrix]).named(name)
    end
    def read_pwm(path_to_pwm)
      parser = Bioinform::MatrixParser.new(fix_nucleotides_number: 16, nucleotides_in: :columns)
      infos = parser.parse(File.read(path_to_pwm))
      name = infos[:name] || File.basename(path_to_pwm, ".#{pwm_extension}")
      Bioinform::MotifModel::DiPWM.new(infos[:matrix]).named(name)
    end
  end
end
