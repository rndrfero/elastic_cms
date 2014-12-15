require 'RMagick'

module Elastic
  module ThumbnailGenerators
  #  include Magick  

    # ---===--- thumbnail generators ---====---
 
    def gallery_tn(src, dest, tn_w=75, tn_h=75)
      Rails.logger.debug "gallery_tn: #{src.inspect}"
  
      #GC.start
      #large = Magick::ImageList.new(src)
      large = Magick::Image.read(src).first
      
      x_ratio = tn_w.to_f / large.columns.to_f
      y_ratio = tn_h.to_f / large.rows.to_f
      
      r = (x_ratio > y_ratio ? x_ratio : y_ratio)        
      tiny = large.resize( r ) 
      
      w = tiny.columns.to_f
      h = tiny.rows.to_f
      off_x = ((w-tn_w) / 2.0)
      off_y = ((h-tn_h) / 2.0)
  
      #toten crop neriesi dobre gify !!!!
  
      tiny.crop!( off_x, off_y, tn_w, tn_h)
      tiny.write(dest)
     
      #GC.start
  
      return off_x.to_s+' '+off_y.to_s   
    end
  
    def max_tn(src, dest, max_w, max_h)
      Rails.logger.debug "max_tn: #{src.inspect}"
    
      GC.start
      orig = Magick::ImageList.new( src)

      orig_w = orig.columns.to_f
      orig_h = orig.rows.to_f
    
      return if orig_w<=max_w and orig_h<=max_h
    
      if (orig_w-max_w) >= (orig_h-max_h) # w is leaking more
        nu = orig.resize max_w.to_f / orig_w.to_f
      else # h is leaking more
        nu = orig.resize max_h.to_f / orig_h.to_f
      end
    
      nu.write(dest)
     
      GC.start
    
      true
    end
  
  end
end