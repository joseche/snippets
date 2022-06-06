# where to store the swap file
SWPFILE=/tmp/swapfile

# decide how much you want to add, 512Mb ?, 1G, 4G ?
# echo $((1024 * 512 ))
# echo $((1024 * 1024 ))
echo $((1024 * 1024 * 4 ))

SIZE=$((1024 * 1024 * 4))

# create the file of that size
dd if=/dev/zero of=$SWPFILE bs=1024 count=$SIZE

# format the file
mkswap $SWPFILE

# attach it
swapon $SWPFILE
