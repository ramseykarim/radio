;+
;COORDINATE TRANSFORMATIONS
;
;    This transformation suite is designed to be an intuitive and 
;    easy-to-remember software for making all 12 possible coordinate
;    transformations between the 4 systems: galactic, horizontal, and
;    both main types of equatorial.
;
;NAME
;    In this program, each coordinate system has a short abbreviaton:
;      Galactic                         : gal
;      Right Ascension and Declination  : radec
;      Hour Angle and Declination       : hadec
;      Horizontal                       : azalt
;
;    To make a transformation, type a function name composed of the
;    abbreviations for the coordinate system you are transforming
;    FROM and then the system you are transforming TO.
;    For example, to go from Galactic to Hour Angle and Dec, you
;    would write out the function GALHADEC, which begins with the
;    abbreviation for Galactic and ends with the abbrevation for
;    Hour Angle and Dec. Then, call that function on your coordinates.
;
;INPUT
;    COORDINATES:
;    Any transformation should only be taking in two coordinates,
;    and you can input them as TRANSFORMATION_CODE(first, second)
;    or you can input them as a 2 element array, such as
;    TRANSFORMATION_CODE([first, second]).
;
;KEYWORDS:
;    HOURS:
;    If you are transforming BETWEEN HADEC and RADEC ONLY, you can
;    use the keyword HOURS to signify that you are inputting your
;    RA or HA in sidereal hours and would like your output in hours
;    as well.
;    Do not use this keyword for other system transformations; it
;    will not work.
;
;    INVERSE:
;    This keyword exists but its usefulness has been abstracted out
;    by your ability to combine abbreviations in any order. It will
;    work with only three of the transformations. I will not specify
;    which three. Do not bother with this keyword.
;
;OUTPUT
;    The function will output the new coordinates in a 1D, 2 element
;    array.
;
;CALLING SEQUENCE
;    new_coords = transformation_code(first, second)
;    or
;    new_coords = transformation_code([first, second])
;       ** Replace 'transformation_code' with a pair of abbreviations.
;
;EXAMPLES
;IDL> horiz_coords = GALAZALT(l, b)
;IDL> radec_coords = HADECRADEC(ha, d)
;IDL> gal_coords = AZALTGAL(az, alt)
;_______________________________________________________________________
;-

function galradec, long, lat, inverse=inverse
  error = 'Something is wrong with your input to RADECHADEC'
  dual_input = size(lat, /type) ne 0
  if not dual_input then begin
     if size(long, /n_dimensions) ne 1 then begin
        print, error
        stop
     endif else begin
        lat = long[1]
        long = long[0]
    endelse
  endif
  radec_latlong = [[-0.054876, -0.873437, -0.483835], $
                   [0.494109, -0.444830, 0.746982], $
                   [-0.867666, -0.198076, 0.455984]]
  latlong_radec = invert(radec_latlong)
  strlong = strtrim(string(long), 1)
  strlat = strtrim(string(lat), 1)
  inv = keyword_set(inverse)
  lat = float(lat)*!dtor
  long = float(long)*!dtor
  x = cos(lat)*cos(long)
  y = cos(lat)*sin(long)
  z = sin(lat)
  vec = [x, y, z]

  if inv then begin
     vecp = radec_latlong ## vec
  endif else begin
     vecp = latlong_radec ## vec
  endelse

  xp = vecp[0]
  yp = vecp[1]
  zp = vecp[2]
  ra = atan(yp, xp)
  dec = asin(zp)

  if inv then begin
     print, 'Galactic Longitude & Latitude of (ra, dec)=('+strlong+', '+strlat+'):'
  endif else begin
     print, 'Right Ascension & Declination of (l, b)=('+strlong+', '+strlat+'):'
  endelse

  returnval = [ra, dec]/!dtor
  print, returnval
  return, returnval
end



function radechadec, ra, dec, inverse=inverse, hours=hours
  error = 'Something is wrong with your input to RADECHADEC'
  dual_input = size(dec, /type) ne 0
  if not dual_input then begin
     if size(ra, /n_dimensions) ne 1 then begin
        print, error
        stop
     endif else begin
        dec = ra[1]
        ra = ra[0]
    endelse
  endif
  hrs = keyword_set(hours)
  lst = ilst()
  lst *= 360./24.
  if hrs then ra *= 360./24.
  inv = keyword_set(inverse)
  strra = strtrim(string(ra), 1)
  strdec = strtrim(string(dec), 1)
  ha = lst - ra
  if hrs then ha *= 24./360.
  if inv then begin
     print, 'Hour Angle and Declination of (ra, dec)=('+strra+', '+strdec+'):'
  endif else begin
     print, 'Right Anscension and Declination of (ha, dec)=('+strra+', '+strdec+'):'
  endelse
  returnval = [ha, dec]
  print, returnval
  return, returnval
end

function hadecazalt, ha, dec, nlat=nlat, hours=hours, inverse=inverse
  error = 'Something is wrong with your input to HADECAZALT'
  dual_input = size(dec, /type) ne 0
  if not dual_input then begin
     if size(ha, /n_dimensions) ne 1 then begin
        print, error
        stop
     endif else begin
        dec = ha[1]
        ha = ha[0]
    endelse
  endif
  latitude = 37.8732*!dtor
  strha = strtrim(string(ha), 1)
  strdec = strtrim(string(dec), 1)
  if keyword_set(nlat) then latitude = float(nlat)
  s = sin(latitude)
  c = cos(latitude)
  matrix = [[-s, 0, c], $
            [0, -1, 0], $
            [c, 0, s]]
  if keyword_set(hours) then ha *= 360./24.
  ha *= !dtor
  dec *= !dtor
  x = cos(dec)*cos(ha)
  y = cos(dec)*sin(ha)
  z = sin(dec)
  vec = [x, y, z]
  if keyword_set(inverse) then matrix = invert(matrix)
  vecp = (matrix ## vec)
  xp = vecp[0]
  yp = vecp[1]
  zp = vecp[2]
  az = atan(yp, xp)
  alt = asin(zp)
  if keyword_set(inverse) then begin
     print, 'Hour Angle and Declination of (az, alt)=('+strha+', '+strdec+'):'
  endif else begin
     print, 'Azimuth and Altitude of (ha, dec)=('+strha+', '+strdec+'):'
  endelse
  returnval = [az, alt]/!dtor
  print, returnval
  return, returnval
end

function galhadec, long, lat
  return, radechadec(galradec(long, lat))
end

function galazalt, long, lat
  return, hadecazalt(galhadec(long, lat))
end

function radecazalt, ra, dec
  return, hadecazalt(radechadec(ra, dec))
end

function azalthadec, az, alt
  return, hadecazalt(az, alt, /inverse)
end

function azaltradec, az, alt
  return, radechadec(azalthadec(az, alt), /inverse)
end

function azaltgal, az, alt
  return, galradec(azaltradec(az, alt), /inverse)
end

function hadecradec, ha, dec
  return, radechadec(ha, dec, /inverse)
end

function hadecgal, ha, dec
  return, galradec(hadecradec(ha, dec), /inverse)
end

function radecgal, ra, dec
  return, galradec(ra, dec, /inverse)
end
