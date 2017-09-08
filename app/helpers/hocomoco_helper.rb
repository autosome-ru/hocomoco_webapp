module HocomocoHelper
  def hocomoco10_url(path)
    "http://hocomoco10.autosome.ru/#{path}"
  end

  def hocomoco10_bundle_url(path)
    "http://hocomoco10.autosome.ru/final_bundle/#{path}"
  end

  def hocomoco11_url(path)
    "#{root_path}#{path}"
  end

  def hocomoco11_bundle_url(path)
    "#{root_path}final_bundle/#{path}"
  end
end
