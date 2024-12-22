module HocomocoHelper
  def hocomoco10_url(path)
    "#{ENV['HOCOMOCO10_URL']}#{path}"
  end

  def hocomoco10_bundle_url(path)
    "#{ENV['HOCOMOCO10_URL']}final_bundle/#{path}"
  end

  def hocomoco11_url(path)
    "#{ENV['HOCOMOCO11_URL']}#{path}"
  end

  def hocomoco11_bundle_url(path)
    "#{ENV['HOCOMOCO11_URL']}final_bundle/hocomoco11/#{path}"
  end

  def hocomoco12_bundle_url(path)
    "#{ENV['HOCOMOCO12_URL']}final_bundle/hocomoco12/#{path}"
  end

  def hocomoco13_bundle_url(path)
    "#{root_path}final_bundle/hocomoco13/#{path}"
  end
end
