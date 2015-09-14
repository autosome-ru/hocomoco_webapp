class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

protected
  def caption(arity, species)
    ((arity == 'di') ? 'Dinucleotide PWMs' : 'PWMs') + " for #{species} transcription factors"
  end

  def quality_help_text(arity)
    case arity
    when 'mono'
      'Only primary high-quality models are shown by default. Use `A to D or S` to view all models.'
    when 'di'
      'Only high-quality models are shown by default. Use `A to D` to view all models.'
    end
  end
end
