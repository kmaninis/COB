function mid = machine_id()
mid = '';
ni = java.net.NetworkInterface.getNetworkInterfaces;
while ni.hasMoreElements
    addr = ni.nextElement.getHardwareAddress;
    if ~isempty(addr)
        addrStr = dec2hex(int16(addr)+128);
        mid = [mid, '.', reshape(addrStr,1,2*length(addr))];
    end
end