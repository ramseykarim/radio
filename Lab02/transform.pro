;+
;
;b=lat
;l=long
;inmode is a variable indicating the the input coordinate system
;outmode is a variable indicating the output coordinate system
;in/outmode values: 0=galactic, 1=equitorial, 2=celestial_2000,
;3=H_celestial, 4=celstial_1950
;-

pro transform, inlong, inlat, inmode, outmode, lst
 inlong = float(inlong)
 inlat = float(inlat)
 lst = float(lst)
 inlong *= !dtor ;convert input to radians
 inlat *= !dtor
 lat = 37.8700 * !dtor ;set local coorinate values
 lon = 122.2590 * !dtor
 lst = lst/12 * !pi 
 x = [cos(inlat) * cos(inlong), cos(inlat) * sin(inlong), sin(inlat)]
 Rlb_ad = [[-0.054876, 0.494109, -0.867666], [-0.873437, -0.444830, -0.198076], [-0.483835, 0.746982, 0.455984]]
 Rlb_ad50 = [[-0.066989, 0.492728, -0.867601], [-0.872756, -0.450347, -0.188375], [-0.483539, 0.744585, 0.460200]]
 Rad_had = [[cos(lst), sin(lst), 0], [sin(lst), -cos(lst), 0], [0, 0, 1]] 
 Rhad_azalt = [[-sin(lat), 0, cos(lat)], [0, -1, 0], [cos(lat), 0, sin(lat)]]
 if (inmode EQ 0) then begin
  gal = x
  alphdel = Rlb_ad ## gal
  halphdel = Rad_had ## alphdel
  altaz = Rhad_azalt ## halphdel
  alph50 = Rlb_ad50 ## gal
 endif else begin
  if (inmode EQ 1) then begin
   altaz = x
   halphdel = transpose(Rhad_azalt) ## altaz
   alphdel = transpose(Rad_had) ## halphdel
   gal = transpose(Rlb_ad) ## alphdel
   alph50 = Rlb_ad50 ## gal
  endif else begin
   if (inmode EQ 2) then begin
    alphdel = x
    halphdel = Rad_had ## alphdel
    altaz = Rhad_azalt ## halphdel
    gal = transpose(Rlb_ad) ## alphdel
    alph50 = Rlb_ad50 ## gal
   endif else begin
    if (inmode EQ 3) then begin
     halphdel = x
     alphdel = transpose(Rad_had) ## halphdel
     altaz = Rhad_azalt ## halphdel
     gal = transpose(Rlb_ad) ## alphdel
     alph50 = Rlb_ad50 ## gal
    endif else begin
     alph50 = x
     gal = transpose(Rlb_ad50) ## alph50
     alphdel = Rlb_ad ## gal
     halphdel = Rad_had ## alphdel
     altaz = Rhad_azalt ## halphdel
    endelse
   endelse
  endelse
 endelse
 if (outmode EQ 0) then out = gal
 if (outmode EQ 1) then out = altaz
 if (outmode EQ 2) then out = alphdel
 if (outmode EQ 3) then out = halphdel
 if (outmode EQ 4) then out = alph50

 lonp = atan(out[1], out[0])
 latp = asin(out[2])
 lonp *= !radeg
 latp *= !radeg
 if (lonp LT 0) then lonp = 360 + lonp
 if (outmode GT 1) then begin
  lonp = lonp/360*24
  print, lonp
  print, latp
 endif else begin
  print, 'begin'
  print, lonp
  print, latp
  print, 'end'
 endelse
end
