;+
;
;-

function len, arr
  return, n_elements(arr)
end

pro pradec, ra, dec
  a = 'ra ='
  d = 'dec ='
  print, a,ra,' ',d,dec
end

pro plb, gl, gb
  l = 'gl ='
  b = 'gb ='
  print, l,gl,' ',b,gb
end

function checkpos, az, alt
  highenough = alt gt 30
  lowenough = alt lt 84
  clearofnorth = (az gt 5) and (az lt 355)
  alltests = highenough and lowenough and clearofnorth
  return, alltests
end

pro priority
  restore, 'pointlist.sav', desc=desc
  gls = transpose(pos[0,*])
  gbs = transpose(pos[1,*])
  glactc, ras, decs, 2016, gls, gbs, 2

  sortras = ras[sort(ras)]
  !p.multi =[0,1,1]
  decasr = decs[sort(ras)]
  decasr -= 90
  decasr *= -1
  t = findgen(50)*2*!pi/49.
  norpolra = t
  norpoldec = t*0 + 7.
;  largerra = t
;  largerdec = t*0 + 60.
  tick0ra = [0, 0, 0]
  tickdec = [55, 60, 65]
  bounds = [-60, 60]

  xaxisv = ['310', '320', '330', '340', '350', '0', '10', '20', '30', '40', '50']
  yaxisv = [-20, 0, 20, 40, 60, 80, 100]
  spinner = float(0)
  increment = (!pi)/12.
  stopping = 1
  while 1 do begin
     erase
     if spinner ge 2*!pi then spinner -= 2*!pi
     strprep = round(spinner*(12./!pi)*100.)/100.
     spinstr = strtrim(string(strprep), 2)
     plot, /polar, decasr, sortras*(!pi/12.) + spinner, $
           /isotropic, xrange=bounds, yrange=bounds, $
           title = 'LST: '+spinstr+' Hours', psym=4, $
           XSTY=4, YSTY=4, POSITION=[0.05,0.05,0.9,0.9]
     oplot, /polar, norpoldec, norpolra, color=!red
     oplot, bounds, [-14, -14], color=!red ;:::::::: HILL
     axis, 0,-37,XAX=0, xrange=[-60,60], xticks=len(xaxisv)-1, $
           xtickname=xaxisv, xtitle='Horizon (Degrees of Azimuth)'
     axis, 0,0,YAX=0, yrange=[-23, 97], yticks=len(yaxisv)-1, $
           ytickv=yaxisv, ytitle='0 Degree Azimuth Meridian (Degrees of Altitude)'
     spinner += increment
     wait, 0.05
     stopper = get_kbrd(0)
     if stopper ne '' then stop
  endwhile

;  stop

  count = 0
  for i=0,len(ras)-1 do begin
     if decs[i] lt (90 - 37) then begin
        print, ras[i],' and ',decs[i]
        count += 1
     endif
  endfor
  print, 'count = ', count
  stop
  rasd = ras*15.


  lst = findgen(240)/10.
  latitude = 37.8732*!dtor
  s = sin(latitude)
  c = cos(latitude)
  matrix = [[-s, 0, c], $
            [0, -1, 0], $
            [c, 0 , s]]
  prioritycount = make_array(1, len(ras), value=0)
  
  for h=0,239 do begin
     hasd = rasd - (lst[h]*15.)
     hasd *= -1
     azalts = []
     for i=0,len(ras)-1 do begin
        x = cos(decs[i]*!dtor)*cos(hasd[i]*!dtor)
        y = cos(decs[i]*!dtor)*sin(hasd[i]*!dtor)
        z = sin(decs[i]*!dtor)
        vec = [x, y, z]
        vecp = matrix ## vec
        xp = vecp[0]
        yp = vecp[1]
        zp = vecp[2]
        az = atan(yp/xp)
        alt = asin(zp)
        azalts = [[azalts], [az, alt]]
     endfor
     azalts /= !dtor
     azs = transpose(azalts[0,*])
     alts = transpose(azalts[1,*])
     hits = checkpos(azs, alts)
     prioritycount += transpose(hits)
  endfor
;  plot, findgen(942), prioritycount
  problems = where(transpose(prioritycount) eq 0)
  print, size(problems)
  for i=0,len(problems)-1 do begin
     print, ras[problems[i]],' ',decs[problems[i]]
  endfor
  stop
  tra = 21.36*15.
  tdec = 86.68
  tazs = []
  talts = []
  for i=0,239 do begin
     hasd = tra - lst[i]*15.
     hasd *= -1
     x = cos(tdec*!dtor)*cos(hasd*!dtor)
     y = cos(tdec*!dtor)*sin(hasd*!dtor)
     z = sin(tdec*!dtor)
     vec = [x, y, z]
     vecp = matrix ## vec
     xp = vecp[0]
     yp = vecp[1]
     zp = vecp[2]
     az = atan(yp/xp)
     alt = asin(zp)
     tazs = [tazs, az/!dtor]
     talts = [talts, alt/!dtor]
  endfor
  !p.multi = [0,1,2]
  plot, lst, tazs, title='az'
  plot, lst, talts, title='alt'
end

function getls, b
  dl = 2./cos(b*!dtor)
  mid = 120.
  howmanyinhalf = ceil(60./dl)
  l = (findgen(2*howmanyinhalf + 1) - howmanyinhalf)*dl + mid
  return, l
end

pro scat
  restore, 'pointlist.sav', desc=desc
  ones = make_array(1, len(pos[0,*]), value=1)
  sphc = [pos, ones]
  rect = cv_coord(FROM_SPHERE=sphc, /TO_RECT, /DEGREES)
  x = transpose(rect[0,*])
  y = transpose(rect[1,*])
  z = transpose(rect[2,*])
;  s = plot3d(x, y, z)

  gls = transpose(pos[0,*])
  gbs = transpose(pos[1,*])
  glactc, ras, decs, 2016, gls, gbs, 2
  sphc1 = [transpose(ras)*15., transpose(decs), ones]
  rect1 = cv_coord(FROM_SPHERE=sphc1, /TO_RECT, /DEGREES)
  x1 = transpose(rect1[0,*])
  y1 = transpose(rect1[1,*])
  z1 = transpose(rect1[2,*])
  rang = [-1,1]
  s1 = plot3d(x1, y1, z1, xrange=rang, yrange=rang, zrange=rang, $
             xtitle='x', ytitle='y', ztitle='z', aspect_ratio=1, $
             aspect_z=1)
  t = findgen(30)*2*!pi/30.
  x2 = sin(t)
  y2 = t*0
  z2 = cos(t)
  s2 = plot3d(x2, y2, z2, /overplot, color='maroon')
end

pro getpos
  b = findgen((60-20)/2.)*2+21
  pos = []
  strc = {pointing, id:0, gl:0, gb:0, ra:0, dec:0, vis:0, lo:0}
  everyother = 0
  for i=0,len(b)-1 do begin
     ls = getls(b[i])
     for j=0,len(ls)-1 do begin
        curstruc = strc
        curstruc.gl = ls[j]
        curstruc.gb = b[i]
        curstruc.id = len(pos)
        curstruc.lo = everyother
        pos = [pos, curstruc]
        everyother = 1 - everyother
     endfor
  endfor
  desc0 = '------------------------------------------------------------'+string(10B)
  desc01 = 'DESCRIPTION of POINTSTRUCLIST.SAV:'+string(10B)
  desc1 = 'variable: POS ->>942 ele array containing struc POINTING'+string(10B)
  desc2 = 'w/ methods ID, GL, GB, RA, DEC, VIS'+string(10B)
  desc3 = 'ID: Identification tag corresponding to array index in POS array'+string(10B)
  desc4 = 'GL: gal longitude'+string(10B)
  desc5 = 'GB: gal latitude'+string(10B)
  desc6 = 'RA: right ascension'+string(10B)
  desc7 = 'DEC: declination'+string(10B)
  desc8 = 'VIS: visibility rating; counts hits of up in best quadrant of sky'+string(10B)
  desc9 = 'LO: local oscillator setting; 0 for lower, 1 for higher'+string(10B)
  totdesc = desc0+desc01+desc1+desc2+desc3+desc4+desc5+desc6+desc7+desc8+desc9+desc0
  print, totdesc

  save, pos, filen='pointstruclist.sav', $
        desc=totdesc
end

