select w1.id
from Weather w1
Join Weather w2
ON w1.recordDate= Date_Add(w2.recordDate, Interval 1 DAY)
where w1.temperature>w2.temperature
