function dout = round15minutes(din)
    m = minute(din);
    m_r = mod(m, 15);
    m = m - m_r + 15*(m_r > 0 && m_r < 7.5);
    dout = datetime(din.Year, din.Month, din.Day, din.Hour, m, 0);
end