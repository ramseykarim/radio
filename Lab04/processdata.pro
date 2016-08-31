;+
; Iterates through all data files collected
; on the Leuschner dish for Lab 4.
;-

function calspec, spec, vels, flatgraph=flatgraph, fitgraph=fitgraph
  gflat = keyword_set(flatgraph)
  gfit = keyword_set(fitgraph)
  if (gflat and gfit) then begin
     print, 'Pick one graph style.'
     stop
  endif
  ndx = where(( (vels gt -220) and (vels lt -190) ) or $
              ( (vels gt -115) and (vels lt  -95) ) or $
              ( (vels gt   80) and (vels lt  110) ) )
  fitvel = vels[ndx]
  fitspec = spec[ndx]
  polyfit_median, fitvel, smooth(fitspec, 1, /nan), 2, coeffs
  fitted = coeffs[2]*vels^2 + coeffs[1]*vels + coeffs[0]
  flatspec = spec / fitted
  flatspec *= 100
  flatspec -= 100
  if not (gflat or gfit) then goto, jumpnone
  if gfit then goto, jumpfit
  !p.multi=[0,1,1]
  plot, vels, smooth(flatspec, 10, /nan), yrange=[-5,5], xrange=[-250,100]
  oplot, [-150, -150], [-10, 10], color=!forest
  oplot, [-50, -50], [-10, 10], color=!forest
  oplot, [0, 0], [-10, 10], color=!forest
  jumpfit:
  plot, vels, spec
  oplot, vels, fitted, color=!forest
  jumpnone:
  clearerrors = check_math()
  return, smooth(flatspec, 1, /nan)
end

pro hi_gfit, spec, vels, tfit, sigma, zro1, hgt1, cen1, wid1, verbose=verbose, quiet=quiet
  zro0 = 0.
  hgt0 = [1., 1., 5.]
  cen0 = [-80, -20, 0]
  wid0 = [20., 5., 10.]
  gfit, -1, vels, spec, zro0, hgt0, cen0, wid0, $
        tfit, sigma, zro1, hgt1, cen1, wid1, $
        sigzro1, sighgt1, sigcen1, sigwid1, problem, cov, $
        quiet=quiet
  if keyword_set(verbose) then begin
     if problem ne 0 then print, 'PROBLEM!',problem
     print, 'sigma',sigma
     print, sigzro1
     print, sighgt1
     print, sigcen1
     print, sigwid1
  endif
end

pro prep_image_velocity
  restore, 'datacomplete.sav', desc=desc
  gls = thedata.gl
  gbs = thedata.gb
  tags = thedata.tag
  ugbs = []
  for i=0,n_elements(tags)-1 do begin
     b = gbs[i]
     if where(ugbs eq b) ne -1 then continue
     ugbs = [ugbs, b]
  endfor
  ugbs = ugbs[sort(ugbs)]
  n_bs = n_elements(ugbs)
  n_ls = 59
  smallval = fltarr(1, 1, 3)
  lbarr_b = fltarr(n_ls, n_bs, 3)
  lbarr_v = fltarr(n_ls, n_bs, 3)
  for i=0,n_bs-1 do begin
     print, 'Doing Lat: ',string(i),' / ',string(n_bs)
     b = ugbs[i]
     lsloc = where(gbs eq b)
     ls = gls[lsloc]
     ls = ls[sort(ls)]
     britevals_lo = []
     velvals_lo = []
     britevals_li = []
     velvals_li = []
     britevals_in = []
     velvals_in = []
     for j=0,n_elements(ls)-1 do begin
        p = where((gbs eq b) and (gls eq ls[j]))
        pnt = thedata[p]
        spec = pnt.yy
        vels = pnt.vrange
        cspec = calspec(spec, vels)
        ndx = where((vels ge -300) and (vels le 100))
        hi_gfit, cspec[ndx], vels[ndx], tfit, sigma, zro1, htg1, cen1, wid1, /quiet
         ; LOW
        vel_lo = cen1[2]
        wid_lo = wid1[2]
        hi_lo = htg1[2]
        if (wid_lo ge 100) then begin
           vel_lo = 0.
           hi_lo = 0.
        endif
        britevals_lo = [britevals_lo, hi_lo]
        velvals_lo = [velvals_lo, vel_lo]
         ; LOW-INT
        vel_li = cen1[1]
        wid_li = wid1[1]
        hi_li = htg1[1]
        if (wid_li ge 100) or (hi_li ge 2) then begin
           vel_li = 0.
           hi_li = 0.
        endif
        britevals_li = [britevals_li, hi_li]
        velvals_li = [velvals_li, vel_li]
         ; INT
        vel_in = cen1[0]
        wid_in = wid1[0]
        hi_in = htg1[0]
        if (wid_in ge 100) or (hi_in ge 2) then begin
           vel_in = 0.
           hi_in = 0.
        endif
        britevals_in = [britevals_in, hi_in]
        velvals_in = [velvals_in, vel_in]
     endfor
     britevals = [[[britevals_lo]], [[britevals_li]], [[britevals_in]]]
     velvals = [[[velvals_lo]], [[velvals_li]], [[velvals_in]]]
     while n_elements(britevals[*, 0, 0]) lt n_ls do begin
        britevals = [smallval, britevals, smallval]
        velvals = [smallval, velvals, smallval]
     end
     lbarr_b[*, i, *] = britevals
     lbarr_v[*, i, *] = velvals
  endfor
  save, lbarr_v, lbarr_b, n_ls, n_bs, filename='VELdcube_3d.sav', $
        desc='LOW:[*, *, 0], LO-INT:[*, *, 1], INT:[*, *, 2]'
end

pro image_velocity, lowplot=lowplot, lowintplot=lowintplot, intplot=intplot, $
                    psch=psch, plot3d=plot3d
  restore, 'VELdcube_3d.sav'
  mult = 8 ; Decided by trial and error
  x = findgen(n_ls*mult)*120./((n_ls-1)*mult) + 60
  x = reverse(x)
  y = findgen(n_bs*mult)*40./((n_bs-1)*mult) + 20.
  pmin_b_lo = min((lbarr_b[*, *, 0])[where(lbarr_b[*, *, 0] gt 0)])
  pmax_b_lo = max(lbarr_b[*, *, 0])
  pmin_b_li = min((lbarr_b[*, *, 1])[where(lbarr_b[*, *, 1] gt 0)])
  pmax_b_li = max(lbarr_b[*, *, 1])
  pmin_b_in = min((lbarr_b[*, *, 2])[where(lbarr_b[*, *, 2] gt 0)])
  pmax_b_in = max(lbarr_b[*, *, 2])

  pmin_v_lo = min((lbarr_v[*, *, 0])[where(lbarr_v[*, *, 0] gt 0)])
  pmax_v_lo = max(lbarr_v[*, *, 0])
  pmin_v_li = min((lbarr_v[*, *, 1])[where(lbarr_v[*, *, 1] gt 0)])
  pmax_v_li = max(lbarr_v[*, *, 1])
  pmin_v_in = min((lbarr_v[*, *, 2])[where(lbarr_v[*, *, 2] gt 0)])
  pmax_v_in = max(lbarr_v[*, *, 2])
  lbarr_b = reverse(lbarr_b)
  lbarr_v = reverse(lbarr_v)*(-1)

  img_b_lo = rebin(lbarr_b[*, *, 0], n_ls*mult, n_bs*mult)
  img_b_li = rebin(lbarr_b[*, *, 1], n_ls*mult, n_bs*mult)
  img_b_in = rebin(lbarr_b[*, *, 2], n_ls*mult, n_bs*mult)

  img_v_lo = rebin(lbarr_v[*, *, 0], n_ls*mult, n_bs*mult)
  img_v_li = rebin(lbarr_v[*, *, 1], n_ls*mult, n_bs*mult)
  img_v_in = rebin(lbarr_v[*, *, 2], n_ls*mult, n_bs*mult)

  latax = findgen(n_bs+2)*40./(n_bs + 1) + 20.
  lonax = findgen(n_ls)*120./(n_ls - 1) + 60.

  lonlines = matrix_multiply((lonax - median(lonax)), cos(latax*!dtor)^(-1))
  latlines = matrix_multiply(make_array(n_elements(lonax), value=1 ), latax) 

  gamma = [.65, .8, .8] ; Decided by trial and error
                        ; and the pursuit of happiness
  saving = keyword_set(psch)
  if keyword_set(lowplot) then goto, jumplo
  if keyword_set(lowintplot) then goto, jumpli
  if keyword_set(intplot) then goto, jumpin
  if keyword_set(plot3d) then goto, jump3d
  print, 'Pck a plaut'
  goto, jumpend
  
  jumplo:
  if saving then begin
     ps_ch, 'COLORPLOT_lo_final.ps', /defaults, /color, xs=12, ys=8, /inch
  endif else begin
     window, 0
  endelse

  display_2d, x, y, img_b_lo, img_v_lo, $
              pmin_b_lo, pmax_b_lo, gamma[0], $
              0, 100, $
              xtitle='Galactic Longitude (deg)', $
              ytitle='Galactic Latitude (deg)', $
              title='Velocity and Intensity Plot: LO', $
              cbar_xtitle='Velocity (infalling, km/s)', $
              cbar_ytitle='Intensity (K)', $
              charsize=1.4
  contour, lonlines, reverse(lonax), latax, nlevels = 10, /overplot
  contour, latlines, reverse(lonax), latax, nlevels = 19, /overplot
  if saving then ps_ch, /close
  goto, jumpend

  jumpli:
  if saving then begin
     ps_ch, 'COLORPLOT_li_final.ps', /defaults, /color, xs=12, ys=8, /inch
  endif else begin
     window, 1
  endelse

  display_2d, x, y, img_b_li, img_v_li, $
              pmin_b_li, pmax_b_li, gamma[1], $
              0, 100, $
              xtitle='Galactic Longitude (deg)', $
              ytitle='Galactic Latitude (deg)', $
              title='Velocity and Intensity Plot: LO-INT', $
              cbar_xtitle='Velocity (infalling, km/s)', $
              cbar_ytitle='Intensity (K)', $
              charsize=1.4
  contour, lonlines, reverse(lonax), latax, nlevels = 10, /overplot
  contour, latlines, reverse(lonax), latax, nlevels = 19, /overplot
  if saving then ps_ch, /close
  goto, jumpend
  
  jumpin:
  if saving then begin
     ps_ch, 'COLORPLOT_in_final.ps', /defaults, /color, xs=12, ys=8, /inch
  endif else begin
     window, 2
  endelse

  display_2d, x, y, img_b_in, img_v_in, $
              pmin_b_in, pmax_b_in, gamma[2], $
              0, 100, $
              xtitle='Galactic Longitude (deg)', $
              ytitle='Galactic Latitude (deg)', $
              title='Velocity and Intensity Plot: INT', $
              cbar_xtitle='Velocity (infalling, km/s)', $
              cbar_ytitle='Intensity (K)', $
              charsize=1.4
  contour, lonlines, reverse(lonax), latax, nlevels = 10, /overplot
  contour, latlines, reverse(lonax), latax, nlevels = 19, /overplot
  if saving then ps_ch, /close
  goto, jumpend

  jump3d:

  img_b_lo = congrid(img_b_lo, 541, 541);/pmax_b_lo
  img_b_li = congrid(img_b_li, 541, 541);/pmax_b_li
  img_b_in = congrid(img_b_in, 541, 541);/pmax_b_in

  img_v_lo = congrid(img_b_lo, 541, 541)
  img_v_li = congrid(img_b_li, 541, 541)
  img_v_in = congrid(img_b_in, 541, 541)

  img_lo = img_b_lo * img_v_lo
  img_li = img_b_li * img_v_li
  img_in = img_b_in * img_v_in

  rgbimg, $
     'Low', 'Red1', 'Red1', .5, img_lo, $
     'Low-Int', 'G1', 'G2', .5, img_li, $
     'Int', 'B1', 'B2', .5, img_in
  
  jumpend:
  print, 'done'
end


pro testhigfit, verbose=verbose
  restore, 'datacomplete.sav'
  nele = n_elements(thedata)
  !p.multi = [0,1,1]
  verby = keyword_set(verbose)
;  for i=0,nele-1 do begin
  i = 511
     pt = thedata[i]
     spec = pt.yy
     vels = pt.vrange
     cspec = calspec(spec, vels)
     ndx = where((vels gt -170) and (vels le 60))
     cspec_f = cspec[ndx]
     vels_f = vels[ndx]
     hi_gfit, cspec_f, vels_f, tfit, sigma, zro1, hgt1, cen1, wid1, verbose=verbose
     erase
     if verby then begin
        print, 'Cents:'
        print, cen1
        print, 'Heights:'
        print, hgt1
        print, 'Offset:'
        print, zro1
        print, 'Widths:'
        print, wid1
        print, '___'
     endif
     ps_ch, 'FitGraph', /color, /default, /inch, xs=12, ys=12
     plot, vels, cspec, title='Fit to three peaks', $
           xrange=[-300,100], yrange=[-10,10], $
           xtitle='Velocity (km/s)', ytitle='Intensity (K)'
     oplot, vels_f, tfit, color=!forest
     ps_ch, /close
;     cont = get_kbrd()
;     if cont eq 'q' then stop
;  endfor
end

function integrate_coldens, spec, vels, bounds
  ndx = where((vels gt bounds[0]) and (vels lt bounds[1]))
  integral = total(spec[ndx])
  return, integral
end



pro prep_image_coldens
  restore, 'datacomplete.sav', desc=desc
  print, desc
  gls = thedata.gl
  gbs = thedata.gb
  tags = thedata.tag
  ugbs = []
  for i=0,n_elements(tags)-1 do begin
     b = gbs[i]
     if where(ugbs eq b) ne -1 then continue
     ugbs = [ugbs, b]
  endfor
  ugbs = ugbs[sort(ugbs)]
  n_bs = n_elements(ugbs)
  n_ls = 59
  zsteps = 301
  smallval = fltarr(1, 1, zsteps)
  lbarr = fltarr(n_ls, n_bs, zsteps)
  for i=0,n_bs-1 do begin
     b = ugbs[i]
     lsloc = where(gbs eq b)
     ls = gls[lsloc]
     ls = ls[sort(ls)]
     vals = []
     for j=0,n_elements(ls)-1 do begin
        p = where((gbs eq b) and (gls eq ls[j]))
        pnt = thedata[p]
        spec = pnt.yy
        vels = pnt.vrange
        cspec = calspec(spec, vels)
        displayvals = []
        for k=0,zsteps-1 do begin
           slicewidth = 20
           slicecent = 50 - k
           slice = [slicecent - slicewidth, slicecent + slicewidth]
           displayval = integrate_coldens(cspec, vels, slice)
           displayvals = [[[displayvals]], [[displayval]]]
        endfor
        vals = [vals, displayvals]
     endfor
     while n_elements(vals[*, 0]) lt n_ls do begin
        vals = [smallval, vals, smallval]
     end
     lbarr[*, i, *] = vals
  endfor
  wherebroken = array_indices(lbarr, where(lbarr eq min(lbarr)))
  wb0 = wherebroken[0]
  wb1 = wherebroken[1]
  wb2 = wherebroken[2]
  avgaround = (lbarr[wb0 - 1, wb1 + 0, wb2] + $
               lbarr[wb0 + 0, wb1 - 1, wb2] + $
               lbarr[wb0 + 1, wb1 + 0, wb2] + $
               lbarr[wb0 + 0, wb1 + 1, wb2])/4.
  lbarr[where(lbarr eq min(lbarr))] = avgaround
  save, lbarr, n_ls, n_bs, zsteps, $
        filename='COLDENSdcube.sav', desc='x=gl, y=gb, z=velocity from 50 to -250'
end

function fiximg, arr
  while where(arr le -50) do stop
  return, 0

end

pro image_coldens, nonrelative=nonrelative
  restore, 'COLDENSdcube.sav', desc=desc
  mult = 25
  practicalmin = min(lbarr[where(lbarr gt 0)])
  practicalmax = max(lbarr)
  nonrel = keyword_set(nonrelative)
  if nonrel then begin
     practicalmin = !null
     practicalmax = !null
  endif
  x = findgen(n_ls*mult)*120./((n_ls-1)*mult) + 60
  x = reverse(x)
  lbarr = reverse(lbarr)
  y = findgen(n_bs*mult)*40./((n_bs-1)*mult) + 20.
  img = rebin(lbarr, n_ls*mult, n_bs*mult, zsteps)
  while 1 do begin
     for k=0,zsteps-151+(nonrel*100) do begin
        ttl1 = strtrim(string(50 - k), 2)
        ttl2 = 'km/s'
        wait, 0.02
        tv, bytscl(img[*, *, k], min=practicalmin, max=practicalmax)
        xyouts, 0.01, 0.3, ttl1, /normal, charsize=3, color=!red, font=1
        xyouts, 0.01, 0.26, ttl2, /normal, charsize=2.5, color=!red, font=1
        if get_kbrd(0) ne '' then stop
     endfor
  endwhile
end


pro lookatdata
  restore, 'datacomplete.sav', desc=desc
  print, desc
  yys = thedata.yy
  vranges = thedata.vrange
  tags = thedata.tag
  los = thedata.lo
  offpoints = thedata.offpoint
  gls = thedata.gl
  gbs = thedata.gb
  for i=0,n_elements(tags)-1 do begin
     spec = yys[*, i]
     vels = vranges[*, i]
     wait, 0.1
     erase
     flat = calspec(spec, vels, /fitgraph)
     if get_kbrd(0) ne '' then stop
  endfor
end



pro processdata, flashthrough=flashthrough, both=both
  restore, 'pointstruclistdone.sav'
  tags = pos.id.tag
  onoffs = pos.lo
  partnerpoints = pos.id.offpoint
  gls = pos.gl
  gbs = pos.gb
  ras = pos.ra
  decs = pos.dec
  allfiles = FILE_SEARCH('./AllData/*.fits.sav')
  thedata = []
  placeholder = dindgen(8192)
  datstc = {pointed, tag:0, order:0, $
            xx:placeholder, yy:placeholder, $
            frange:placeholder, vrange:placeholder, $
            gl:0d0, gb:0d0, lo:0, ra:0d0, dec:0d0, $
            offpoint:0}
  graphing = keyword_set(flashthrough)
  both = keyword_set(both)
  !p.multi=[0,1,1+both]
  for i=0,n_elements(allfiles)-1 do begin
     restore, allfiles[i]
     name = fst.srcname
     ugdoppler = fst.ugdopp
     ordernum = i
     tagnum = strpos(name, 'TAG')
     tagnum += 3
     tag_und = strmid(name, tagnum)
     tagstr = strmid(tag_und, 0, strlen(tag_und)-1)     
     tag = fix(tagstr)
     spctxx = fst.spct_avg[*, 0]
     spctyy = fst.spct_avg[*, 1]
     frq0 = fst.freq_rf_chnl0
     frq8191 = fst.freq_rf_chnl8191
     freqs = dindgen(8192)*(frq8191 - frq0)/8191. + frq0
     ; Calcs done in kHz, km/s
     lsrv = ugdoppler[3]
     value21 = 4.73
     diff21 = 1420405.75 - (freqs/(10.^3))
     vels = (diff21/value21) - lsrv
     cur_point = datstc
     cur_point.tag = tag
     cur_point.order = ordernum
     cur_point.xx = spctxx
     cur_point.yy = spctyy
     cur_point.frange = freqs
     cur_point.vrange = vels
     cur_point.gl = gls[tag]
     cur_point.gb = gbs[tag]
     cur_point.ra = ras[tag]
     cur_point.dec = decs[tag]
     cur_point.lo = onoffs[tag]
     cur_point.offpoint = partnerpoints[tag]
     thedata = [thedata, cur_point]
     if graphing then begin
        wait, 0.05
        erase
        if both then begin
           plot, vels, smooth(spctxx, 10), title='xx', $
                 xrange=[-200, 200], ysty=1, charsize=1.5, $
                 xtitle='Velocities (km/s)'
        endif
        plot, vels, smooth(spctyy, 3), title='yy', $
              ysty=1, charsize=1.5, xrange=[-300, 100], $
              xtitle='Velocities (km/s)'
     endif
     stopper = get_kbrd(0)
     if stopper ne '' then stop
  endfor
  nl = string(10B)
  desc0 = '-----------------------------------------------'+nl
  desc1 = 'THEDATA: contains everything we need from Leuschner for Lab 4'+nl
  desc2 = 'Methods:'+nl+nl
  desc3 = 'TAG: unique tag corresponding to index in POS list'+nl
  desc4 = 'ORDER: number corresponding to the order of the points taken'+nl
  desc5 = 'XX: xx polarization averaged spectrum, 8192 ele array'+nl
  desc5 = 'YY: yy polarization averaged spectrum, 8192 ele array'+nl
  desc6 = 'FRANGE: frequencies for each channel, 8192 ele array'+nl
  desc7 = 'VRANGE: velocities for each channel, 8192 ele array'+nl
  desc8 = 'GL: galactic longitude, DEGREES'+nl
  desc9 = 'GB: galactic latitude, DEGREES'+nl
  desc10 = 'LO: local oscillator setting; 0 if 1418.4, 1 if 1422.4 (MHz)'+nl
  desc11 = 'RA: right ascension in HOURS'+nl
  desc12 = 'DEC: declination in DEGREES'+nl
  desc13 = 'OFFPOINT: TAG of offline paired point'+nl
  desc = desc0+desc1+desc2+desc3+desc4+desc5+desc6
  desc += desc7+desc8+desc9+desc10+desc11+desc12+desc13+desc0
  save, thedata, filen='datacomplete.sav', desc=desc
  print, desc
end

pro checkdones
  restore, 'pointstruclistdone.sav', /verb, desc=desc
  dones = pos.done
  tags = pos.id.tag
  locs = pos.id.loc
  print, tags[where(dones eq 0)]
end
