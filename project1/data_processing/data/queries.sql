-- The northbound first appearance time above 11th street
select min(epoch_ms) from cars where direction=2 and intersection=3 group by vehicle_id order by epoch_ms;

-- The southbound first appearnce time above 12th street
select min(epoch_ms) from cars where direction=4 and intersection=3 group by vehicle_id order by epoch_ms;

-- The northward cars turning left
select min(epoch_ms) from cars where direction=2 and intersection=3 and movement=2 group by vehicle_id;

-- The northward cars turning right
select min(epoch_ms) from cars where direction=2 and intersection=3 and movement=3 group by vehicle_id;

-- The norward cars going straight
select min(epoch_ms) from cars where direction=2 and intersection=3 and movement=1 group by vehicle_id;

-- The southward cars turning left
select min(epoch_ms) from cars where direction=4 and intersection=3 and movement=2 group by vehicle_id;

-- The southward cars turning right
select min(epoch_ms) from cars where direction=4 and intersection=3 and movement=3 group by vehicle_id;

-- The sourthward cars going straight
select min(epoch_ms) from cars where direction=4 and intersection=3 and movement=1 group by vehicle_id;