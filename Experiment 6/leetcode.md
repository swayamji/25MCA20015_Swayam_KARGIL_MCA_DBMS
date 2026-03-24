Ques: 570. Managers with at Least 5 Direct Reports


<img width="1920" height="989" alt="image" src="https://github.com/user-attachments/assets/da7202f2-994a-4f94-8163-9035ed622c63" />

SELECT name FROM Employee WHERE id IN (select managerId from Employee  GROUP BY managerId HAVING COUNT(managerId) > 4);
