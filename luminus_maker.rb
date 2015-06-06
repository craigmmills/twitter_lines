
require 'rubygems'
require 'DBF'
require 'georuby'
require 'openssl'
require 'geokit'
require 'geo_ruby/shp' 

include GeoRuby::Shp4r


#make the shapefile
new_shpfile = ShpFile.open("output/tw_si_out.shp")
shpfile = "tw_si.shp"

#reading the shape file
ShpFile.open(shpfile) do |shp|

	orig = Geokit::LatLng.new(0,0) #start with single pt to test - will need to change for track loc

    shp.each do |shape|
    	print '.'
	    geom = shape.geometry
	    att_data = shape.data 

	    #add first pt to shp
	    new_shpfile.transaction do |tr|
	    	tr.add(ShpRecord.new(geom, 'cartodb_id' => att_data['cartodb_id'],'epoch' => att_data['intdat'], 'orderpt' => 1))
		end


		start_pt = Geokit::LatLng.new(geom.y, geom.x)
		dist = orig.distance_to(start_pt)
		bear = start_pt.heading_to(orig)

		2.upto(10) {|i|

			tmp_geom = start_pt.endpoint(bear,(dist/10)*(i-1))
			new_shpfile.transaction do |tr|
		    	tr.add(ShpRecord.new(GeoRuby::SimpleFeatures::Point.from_x_y(tmp_geom.longitude, tmp_geom.latitude), 'cartodb_id' => att_data['cartodb_id'],'epoch' => att_data['intdat']+(i*3600), 'orderpt' => i))
			end

		}
     
    end
 end

 shpfile.close
 new_shpfile.close


