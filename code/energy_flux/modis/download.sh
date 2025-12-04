for i in {1..30}; do
    day=$(printf "%03d" "$i")
    wget -e robots=off -m -np -R .html,.tmp -nH --cut-dirs=3 \
        "https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/61/MOD06_L2/2021/${day}/" \
        --header "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJvcmlnaW4iOiJFYXJ0aGRhdGEgTG9naW4iLCJzaWciOiJlZGxqd3RwdWJrZXlfb3BzIiwiYWxnIjoiUlMyNTYifQ.eyJ0eXBlIjoiVXNlciIsInVpZCI6ImFub3JhYWFiaXUiLCJleHAiOjE3Njc0MTYyODAsImlhdCI6MTc2MjIzMjI4MCwiaXNzIjoiaHR0cHM6Ly91cnMuZWFydGhkYXRhLm5hc2EuZ292IiwiaWRlbnRpdHlfcHJvdmlkZXIiOiJlZGxfb3BzIiwiYWNyIjoiZWRsIiwiYXNzdXJhbmNlX2xldmVsIjozfQ.APCNFHIByotKczoMnep74D-nzzfVbd90XDITTQKa3SNgf9ovE1yvatgno7LdvqAVUkcTQeeyO0qLMm5W3IBn3PVV05GMh0rtjwZglVngnJzuqutJ-zoWOqcn_cUIx1UpR93Jv_iEL3WDktBZn8AET7J0FXjmL-N0iDj3TCjoRtQsS7ofALat5KY5kfvXPLs04MdMo7-K5kpTREgkR-hb9Gd5eAr3_MasFaQIuLbjDb3q3fdI7CdjjE5SLZGHnYcdevU2CHz7TqZ0e8hZQnWTdnrorYcK2zF_MuTrVciQvG1Zczogig_s24xVlNQ0M4z7iUgxHyvcHz-R2VcjP9kYCw" \
        -P "/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding_Anora/MODIS_L2"
done


for i in {1..30}; do
    day=$(printf "%03d" "$i")
    wget -e robots=off -m -np -R .html,.tmp -nH --cut-dirs=3 \
        "https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/61/MOD03/2021/${day}/" \
        --header "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJvcmlnaW4iOiJFYXJ0aGRhdGEgTG9naW4iLCJzaWciOiJlZGxqd3RwdWJrZXlfb3BzIiwiYWxnIjoiUlMyNTYifQ.eyJ0eXBlIjoiVXNlciIsInVpZCI6ImFub3JhYWFiaXUiLCJleHAiOjE3Njc0MTYyODAsImlhdCI6MTc2MjIzMjI4MCwiaXNzIjoiaHR0cHM6Ly91cnMuZWFydGhkYXRhLm5hc2EuZ292IiwiaWRlbnRpdHlfcHJvdmlkZXIiOiJlZGxfb3BzIiwiYWNyIjoiZWRsIiwiYXNzdXJhbmNlX2xldmVsIjozfQ.APCNFHIByotKczoMnep74D-nzzfVbd90XDITTQKa3SNgf9ovE1yvatgno7LdvqAVUkcTQeeyO0qLMm5W3IBn3PVV05GMh0rtjwZglVngnJzuqutJ-zoWOqcn_cUIx1UpR93Jv_iEL3WDktBZn8AET7J0FXjmL-N0iDj3TCjoRtQsS7ofALat5KY5kfvXPLs04MdMo7-K5kpTREgkR-hb9Gd5eAr3_MasFaQIuLbjDb3q3fdI7CdjjE5SLZGHnYcdevU2CHz7TqZ0e8hZQnWTdnrorYcK2zF_MuTrVciQvG1Zczogig_s24xVlNQ0M4z7iUgxHyvcHz-R2VcjP9kYCw" \
        -P "/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding_Anora/MODIS_L2"
done