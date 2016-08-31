galcoords = [120,0]
.com ~/transforms_rams.pro
radec = galradec(galcoords, /sil)
decc = radec[1]
raa = radec[0]/15.
print, 'RA in Hours: ',raa
print, 'Dec (deg): ', decc
lst = lstnow()
hanow = lst - raa
azalt = galazalt(120, 0, /sil)
print, 'Hour Angle (hours) right now: ', hanow
