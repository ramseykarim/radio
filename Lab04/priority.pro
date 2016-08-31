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

pro projections_ignorant
  restore, './Day2Data/pointstruclist325.sav'
  dones = pos.done



  restore, 'pointstruclist.sav', desc=desc
  ras = pos.ra
  decs = pos.dec
  !p.multi =[0,1,1]

;  cvec = [!white, !purple, !blue, $
;          !forest, !green, !cyan, $
;          !yellow, !magenta, !orange, $
;          !red]

  decs -= 90
  decs *= -1
  t = findgen(50)*2*!pi/49.
  norpolra = t
  norpoldec = t*0 + 7.
  tick0ra = [0, 0, 0]
  tickdec = [55, 60, 65]
  bounds = [-60, 60]
  xaxisv = ['310', '320', '330', '340', '350', '0', '10', '20', '30', '40', '50']
  yaxisv = [-20, 0, 20, 40, 60, 80, 100]
  spinner = float(0)
  increment = (!pi)/48.
  
  dra = []
  ddec = []
  ndra = []
  nddec = []
;  for i=0,len(decs)-1 do begin
;     if dones[i] then begin
        

;  delayer = 0
;  cspinner = 0

  while 1 do begin
     wait, 0.02
     erase
     if spinner ge 2*!pi then spinner -= 2*!pi
     strprep = round(spinner*(12./!pi)*100.)/100.
     spinstr = strtrim(string(strprep), 2)
     plot, /polar, decs, ras*(!pi/12.) + spinner, $
           /isotropic, xrange=bounds, yrange=bounds, $
           title = 'LST: '+spinstr+' Hours', psym=4, $
           XSTY=4, YSTY=4, POSITION=[0.05,0.05,0.9,0.9];, $
;           color=cvec[cspinner]
     oplot, /polar, norpoldec, norpolra, color=!red
     oplot, bounds, [-14, -14], color=!red ;:::::::: HILL
     axis, 0,-37,XAX=0, xrange=[-60,60], xticks=len(xaxisv)-1, $
           xtickname=xaxisv, xtitle='Horizon (Degrees of Azimuth)'
     axis, 0,0,YAX=0, yrange=[-23, 97], yticks=len(yaxisv)-1, $
           ytickv=yaxisv, ytitle='0 Degree Azimuth Meridian (Degrees of Altitude)'
     spinner += increment
     stopper = get_kbrd(0)
     if stopper ne '' then stop
;     delayer += 1
;     if delayer mod 10 eq 0 then cspinner += 1
;     if cspinner eq len(cvec) then cspinner -= len(cvec)
  endwhile  
end

pro projections, equatorial=equatorial, topocentric=topocentric, $
                 altaz=altaz, azalt=azalt, alltopocentric=alltopocentric

  latitude = 37.8732*!dtor
  s = sin(latitude)
  c = cos(latitude)
  matrix = [[-s, 0, c], $
            [0, -1, 0], $
            [c, 0 , s]]
  restore, 'pointstruclist.sav', desc=desc
  ras = pos.ra
  decs = pos.dec
  spinner = float(0)
  increment = (!pi)/48.
  eqa = keyword_set(equatorial)
  topo = keyword_set(topocentric)
  topo3 = keyword_set(alltopocentric)
  aa = keyword_set(altaz) or keyword_set(azalt)
  while 1 do begin
     wait, 0.011
     if topo or topo3 then begin
        xps = []
        yps = []
        zps = []     
     endif
     if eqa then begin
        xs = []
        ys = []
        zs = []
     endif
     if aa then begin
        azs = []
        alts = []
     endif
     for p=0,max(pos.id.tag) do begin
        cur_ra = ras[p]*(!pi/12.)
        cur_dec = decs[p]*!dtor
        cur_ha = spinner - cur_ra
        if cur_ha gt 2*!pi then cur_ha -= 2*!pi
        x = cos(cur_dec)*cos(cur_ha)
        y = cos(cur_dec)*sin(cur_ha)
        z = sin(cur_dec)
        vec = [x, y, z]
        vecp = matrix ## vec
        xp = vecp[0]
        yp = vecp[1]
        zp = vecp[2]
        az = atan(yp, xp)/!dtor
        if az lt 0 then az += 360.
        alt = asin(zp)/!dtor
        if topo or topo3 then begin
           xps = [xps, xp]
           yps = [yps, yp]
           zps = [zps, zp]
        endif
        if eqa then begin
           xs = [xs, x]
           ys = [ys, y]
           zs = [zs, z]
        endif
        if aa then begin
           azs = [azs, az]
           alts = [alts, alt]
        endif
     endfor
     erase
     
     if (topo or aa) and (not topo3) and (not eqa) then begin
        rows = 1
     endif else begin
        rows = 2
     end
     !p.multi=[0,rows,(topo + topo3 + aa + eqa)]


 ;             Topocentric Projection, facing Zenith, alt/az
     if aa then begin
        posalt = alts[where(alts ge 0, /null)]
        posaz = azs[where(alts ge 0, /null)]
        negalt = alts[where(alts lt 0, /null)]
        negaz = azs[where(alts lt 0, /null)]
        if not (posalt eq !null) then begin
           posalt = (posalt - 90)*(-1)
           posaz *= !dtor
        endif
        if not (negalt eq !null) then begin
           negalt += 90
           negaz *= !dtor
        endif
        plot, /polar, azs, alts, /nodata, color=!white, $
              title='Topocentric - Azimuth and Altitude', $
              xrange=[-10, 90], yrange=[-90,90]
        oplot, [0], [0], color=!red, psym=2, symsize=3
        if not (posalt eq !null) then begin
           oplot, /polar, posalt, posaz, color=!magenta, $
                  psym=4
        endif
        if not (negalt eq !null) then begin
           oplot, /polar, negalt, negaz, color=!purple, $
                  psym=4
        endif
     endif


     if topo then begin
 ;             Topocentric projections, xyz
        posxpswrty = xps[where(yps ge 0)]
        poszpswrty = zps[where(yps ge 0)]
        negxpswrty = xps[where(yps lt 0)]
        negzpswrty = zps[where(yps lt 0)]
        highyps = yps[where(xps ge 0.6)]
        highzps = zps[where(xps ge 0.6)]
        lowyps = yps[where(xps lt 0.6)]
        lowzps = zps[where(xps lt 0.6)]
        posxpswrtz = xps[where(zps ge 0, /null)]
        posypswrtz = yps[where(zps ge 0, /null)]
        negxpswrtz = xps[where(zps lt 0, /null)]
        negypswrtz = yps[where(zps lt 0, /null)]

        plot, xps, zps, /nodata, xrange=[-1,1], yrange=[-1,1], $
              /isotropic, xsty=4, ysty=4, color=!white, $
              title='Topocentric - y and z'
        oplot, highyps, highzps, color=!forest, psym=4
        oplot, lowyps, lowzps, color=!green, psym=4
        axis, 0,0, xax=0, xtitle='y'
        axis, 0,0, yax=0, ytitle='z'
        
     endif
     if topo3 then begin

        plot, xps, zps, /nodata, xrange=[-1,1], yrange=[-1,1], $
              /isotropic, xsty=4, ysty=4, color=!white, $
              title='Topocentric - x and z'
        oplot, posxpswrty, poszpswrty, psym=4, color=!cyan
        oplot, negxpswrty, negzpswrty, psym=4, color=!blue     
        axis, 0,0, xax=0, xtitle='x'
        axis, 0,0, yax=0, ytitle='z'

        plot, xps, yps, /nodata, xrange=[-1,1], yrange=[-1,1], $
              /isotropic, xsty=4, ysty=4, color=!white, $
              title='Topocentric - x and y'
        if not (posxpswrtz eq !null) then begin 
           oplot, posxpswrtz, posypswrtz, color=!yellow, psym=4
        endif
        if not (negxpswrtz eq !null) then begin
        oplot, negxpswrtz, negypswrtz, color=!orange, psym=4
        endif
        axis, 0,0, xax=0, xtitle='x'
        axis, 0,0, yax=0, ytitle='y'
        
        plot, xps, yps, /nodata, xsty=4, ysty=4, $
              xrange=[-1,1], yrange=[-1,1]
     endif

 ;             Equatorial projections, xyz
     if eqa then begin
        posxswrty = xs[where(ys ge 0)]
        poszswrty = zs[where(ys ge 0)]
        negxswrty = xs[where(ys lt 0)]
        negzswrty = zs[where(ys lt 0)]
        posyswrtx = ys[where(xs ge 0)]
        poszswrtx = zs[where(xs ge 0)]
        negyswrtx = ys[where(xs lt 0)]
        negzswrtx = zs[where(xs lt 0)]
        
        plot, xs, zs, /nodata, xrange=[-1,1], yrange=[-1,1], $
              /isotropic, xsty=4, ysty=4, color=!white, $
              title='Equatorial - y and z'
        oplot, ys, zs, color=!forest, psym=4
        oplot, posyswrtx, poszswrtx, color=!forest, psym=4
        oplot, negyswrtx, negzswrtx, color=!green, psym=4
        axis, 0,0, xax=0
        axis, 0,0, yax=0
        
        plot, xs, zs, /nodata, xrange=[-1,1], yrange=[-1,1], $
              /isotropic, xsty=4, ysty=4, color=!white, $
              title='Equatorial - x and z'
        oplot, posxswrty, poszswrty, psym=4, color=!cyan
        oplot, negxswrty, negzswrty, psym=4, color=!blue     
        axis, 0,0, xax=0
        axis, 0,0, yax=0
     endif



     spinner += increment
     stopper = get_kbrd(0)
     if stopper ne '' then stop
  endwhile
end


function checkpos, az, alt
  highenough = alt gt 25
  lowenough = alt lt 84
  clearofnorth = (az gt 280) and (az lt 360)
  alltests = highenough and lowenough and clearofnorth
  return, alltests
end

pro getvis
  restore, 'pointstruclist.sav', desc=desc
  descadd = string(10B)+'VISIBILITIES ADDED'
  desc = desc+descadd
  ras = pos.ra
  decs = pos.dec
  !p.multi =[0,1,1]
  decs -= 90
  decs *= -1
  t = findgen(50)*2*!pi/49.
  norpolra = t
  norpoldec = t*0 + 7.
  tick0ra = [0, 0, 0]
  tickdec = [55, 60, 65]
  bounds = [-60, 60]
  xaxisv = ['310', '320', '330', '340', '350', '0', '10', '20', '30', '40', '50']
  yaxisv = [-20, 0, 20, 40, 60, 80, 100]
  spinner = float(0)
  increment = (!pi)/48.
  latitude = 37.8732*!dtor
  s = sin(latitude)
  c = cos(latitude)
  matrix = [[-s, 0, c], $
            [0, -1, 0], $
            [c, 0 , s]]

  while spinner le 2*!pi do begin
     wait, 0.02
     erase
     if spinner gt 2*!pi then spinner -= 2*!pi
     strprep = round(spinner*(12./!pi)*100.)/100.
     spinstr = strtrim(string(strprep), 2)
     plot, /polar, decs, ras*(!pi/12.) + spinner, $
           /isotropic, xrange=bounds, yrange=bounds, $
           title = 'LST: '+spinstr+' Hours', psym=4, $
           XSTY=4, YSTY=4, POSITION=[0.05,0.05,0.9,0.9]
     oplot, /polar, norpoldec, norpolra, color=!red
     oplot, bounds, [-14, -14], color=!red ;:::::::: HILL
     axis, 0,-37,XAX=0, xrange=[-60,60], xticks=len(xaxisv)-1, $
           xtickname=xaxisv, xtitle='Horizon (Degrees of Azimuth)'
     axis, 0,0,YAX=0, yrange=[-23, 97], yticks=len(yaxisv)-1, $
           ytickv=yaxisv, ytitle='0 Degree Azimuth Meridian (Degrees of Altitude)'
     oplot, [-60, -1, -1, -60, -60], [-12, -12, 47, 47, -12], color=!green, psym=-4
     oplot, /polar, [90. - pos[941].dec], [pos[941].ra]*(!pi/12.) + spinner, $
            color=!cyan, psym = 4
     spinner += increment
     

     lst_r = spinner
     hitlist = make_array(1, max(pos.id.tag)+1)
     for p=0,max(pos.id.tag) do begin
        cur_ra_r = pos[p].ra*(15.*!dtor)
        cur_dec_r = pos[p].dec*!dtor
        cur_ha_r = lst_r - cur_ra_r
        x = cos(cur_dec_r)*cos(cur_ha_r)
        y = cos(cur_dec_r)*sin(cur_ha_r)
        z = sin(cur_dec_r)
        vec = [x, y, z]
        vecp = matrix ## vec
        xp = vecp[0]
        yp = vecp[1]
        zp = vecp[2]
        az = atan(yp, xp)/!dtor
        if az le 0 then az += 360.
        alt = asin(zp)/!dtor
        isitthere = checkpos(az, alt)
        hitlist[p] += isitthere
     endfor
     pos.vis += hitlist
  endwhile
  print, pos.vis*0.25
  print, size(where(pos.vis eq 0, /null), /n_elements)
  save, pos, filename='pointstruclist.sav', desc=desc
end

pro checkposlist
  restore, 'pointstruclist.sav', desc=desc, /verb
  print, pos.id.tag
  print, pos.vis
end




pro plothillmap
  restore, 'boolhillmap.sav', /verbose, desc=desc
  print, desc
  help, bool_map
  contour, bool_map, findgen(60)*3, findgen(22)*3, /fill
end


pro priority_old
  restore, 'pointlist.sav', desc=desc
  gls = transpose(pos[0,*])
  gbs = transpose(pos[1,*])
  glactc, ras, decs, 2016, gls, gbs, 2
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

pro showpairs
  restore, 'pointstruclist.sav', desc=desc
  plot, [-1,max(pos.id.loc[0])+1], [-1,max(pos.id.loc[1])+1], /nodata, $
        title='Point Pairs'
  for p=0,max(pos.id.tag) do begin
     pointloc = pos[p].id.loc
     otherpoint = pos[p].id.offpoint
     otherpointloc = pos[otherpoint].id.loc
     xs = [pointloc[0], otherpointloc[0]]
     ys = [pointloc[1], otherpointloc[1]]
     oplot, xs, ys, psym=-4
  endfor
  for p=0,max(pos.id.tag) do begin
     pointloc = pos[p].id.loc
     onoroff = pos[p].lo
     if onoroff then begin
        c1 = !green
        c2 = !red
     endif else begin
        c1 = !red
        c2 = !green
     endelse
     otherpoint = pos[p].id.offpoint
     otherpointloc = pos[otherpoint].id.loc
     oplot, [pointloc[0]], [pointloc[1]], color=c1, psym=4
     oplot, [otherpointloc[0]], [otherpointloc[1]], color=c2, psym=4
  endfor
end

pro scat
  restore, 'pointlist.sav', desc=desc
  ones = make_array(1, len(pos[0,*]), value=1)

  gls = transpose(pos[0,*])
  gbs = transpose(pos[1,*])
  glactc, ras, decs, 2016, gls, gbs, 2
  rang = [-1,1]
  t = findgen(30)*2*!pi/30.
  xc = sin(t)
  yc = t*0
  zc = cos(t)

  sphc = [transpose(ras)*15., transpose(decs), ones]
  stopper = 1
  while stopper le 30 do begin
     sphc[0,*] += 10.
     rect = cv_coord(FROM_SPHERE=sphc, /TO_RECT, /DEGREES)
     x = transpose(rect[0,*])
     y = transpose(rect[1,*])
     z = transpose(rect[2,*])
     s = plot3d(xc, yc, zc, xrange=rang, yrange=rang, zrange=rang, $
                xtitle='x', ytitle='y', ztitle='z', aspect_ratio=1, $
                aspect_z=1, /current)
     w = s.window
     sd = plot3d(x, y, z, /overplot, color='maroon', /current)
     wait, 0.5
     stopper += 1
     if stopper le 30 then w.erase
  endwhile
end

function getls, b
  dl = 2./cos(b*!dtor)
  mid = 120.
  howmanyinhalf = ceil(60./dl)
  l = (findgen(2*howmanyinhalf + 1) - howmanyinhalf)*dl + mid
  return, l
end

pro getpos
  b = findgen((60-20)/2.)*2+21
  pos = []
  strc = {pointing, id:{id, tag:0, loc:[0,0], offpoint:0}, $
          gl:0d0, gb:0d0, ra:0d0, dec:0d0, $
          vis:0, lo:0, done:0}
  everyother = 0
  for i=0,len(b)-1 do begin
     ls = getls(b[i])
     for j=0,len(ls)-1 do begin
        curstruc = strc
        curstruc.gl = ls[j]
        curstruc.gb = b[i]
        curstruc.id.tag = len(pos)
        curstruc.id.loc = [i, j]
        curstruc.lo = everyother
        pos = [pos, curstruc]
        everyother = 1 - everyother
     endfor
  endfor
  for p=0,max(pos.id.tag) do begin
     plist = []
     curloc = pos[p].id.loc
     curloset = pos[p].lo
     for i=0,max(pos.id.tag) do begin
        if i eq p then continue
        cursubloset = pos[i].lo
        if curloset eq cursubloset then continue
        cursubloc = pos[i].id.loc
        dist = (curloc[0] - cursubloc[0])^2 + (curloc[1] - cursubloc[1])^2
        diststruc = {which:i, d:dist}
        plist = [plist, diststruc]
     endfor
     least = where(plist.d eq min(plist.d))
     least = least[0]
     best = plist[least].which
     pos[p].id.offpoint = best
  endfor
  desc0 = '------------------------------------------------------------'+string(10B)
  desc01 = 'DESCRIPTION of POINTSTRUCLIST.SAV:'+string(10B)
  desc1 = 'variable: POS ->>942 ele array containing struc POINTING'+string(10B)
  desc2 = 'w/ methods ID, GL, GB, RA, DEC, VIS, LO, DONE'+string(10B)
  desc3a = 'ID: Identification tag containing ID structure:'+string(10B)
  desc3b = '     - TAG: tag corresponding to array index in POS array'+string(10B)
  desc3c = '     - LOC: 2ele array corresponding to (gb, gl) index in integers'+string(10B)
  desc3d = '     - OFFPOINT: POS.ID.TAG of the nearest point w/ opposite POS.LO'+string(10B)
  desc3 = desc3a+desc3b+desc3c+desc3d
  desc4 = 'GL: gal longitude'+string(10B)
  desc5 = 'GB: gal latitude'+string(10B)
  desc6 = 'RA: right ascension'+string(10B)
  desc7 = 'DEC: declination'+string(10B)
  desc8 = 'VIS: visibility rating; counts hits of up in best quadrant of sky'+string(10B)
  desc9 = 'LO: local oscillator setting; 0 for lower, 1 for higher'+string(10B)
  desc10 = 'DONE: 1 if taken, 0 if needs to be taken'+string(10B)
  totdesc = desc0+desc01+desc1+desc2+desc3+desc4+desc5+desc6+desc7+desc8+desc9+desc10+desc0
  print, totdesc


  gls = pos.gl
  gbs = pos.gb
  glactc, ras, decs, 2016, gls, gbs, 2
  pos.ra = ras
  pos.dec = decs

  atpoint = where((gls ge 115) and (gls le 125) $
                  and (gbs ge 45) and (gbs le 55))
  print, atpoint
  
;  save, pos, filen='pointstruclist.sav', $
;        desc=totdesc
end

