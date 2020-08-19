<?php

$page_title = "Bookings";

include_once('includes/header.html');
require_once('database_classes/database.php');
require_once('login_tools.php');

# redirect to login page if not logged in
if (!isset($_SESSION['customerId']))
{
	load();
}

?>

<section role="contentinfo" aria-label="Flightcrew bookings page">
<div class="container">
    <div class="row">
        <h2 class="bg-dark text-white">Bookings</h2>
    </div>
	<div class="row">
        <?php
		$customerId = $_SESSION['customerId'];
		$database = new Database();
		# retrieve bookings by customerID
		$rowSet = $database->bookings($customerId);

		if($rowSet)
		{
			print '<h3 class="text-info">Uncomfirmed bookings:</h3>';
            print "<table class=\"table table-bordered\">";
            print "<thead><tr><th scope='col'>AppointmentCode</th>";
            print "<th scope='col'>Date</th>";
            print "<th scope='col'>Start Time</th>";
            print "<th scope='col'>End Time</th></tr></thead>";


            foreach ($rowSet as $row)
            {
                print "<tbody><tr><td>".$row['FlightPlanCode']."</td>";
                print "<td>".$row['JourneyDateFormatted']."</td>";
                print "<td>".$row['JourneyDepartureTime']."</td>";
                print "<td>".$row['JourneyArrivalTime']."</td>";
                print '<td><a href="pay.php?id='.$row['BookingID'].'" class="btn btn-info">confirm booking</a></td>';
                print '<td><a href="booking_cancelled.php?id='.$row['BookingID'].'" class="btn btn-info">Cancel</a></td></tr></tbody>';
            }
            print "</table>";
		}
		else
		{
			print '<h3 class="text-info">You do not have any uncomfirmed bookings.</h3>';
		}
		
		?>
    </div>
	<div class="row">
        <?php
		$customerId = $_SESSION['customerId'];
		$database = new Database();
		# retrieve bookings by customerID
		$rowSet = $database->confirmedBookings($customerId);

		if($rowSet)
		{
			print '<h3 class="text-info">Comfirmed bookings:</h3>';
            print "<table class=\"table table-bordered\">";
            print "<thead><tr><th scope='col'>Appointment Code</th>";
            print "<th scope='col'>Date</th>";
            print "<th scope='col'> start Time</th>";
            print "<th scope='col'>end Time</th></tr></thead>";

            foreach ($rowSet as $row)
            {
                print "<tbody><tr><td>".$row['FlightPlanCode']."</td>";
                print "<td>".$row['JourneyDateFormatted']."</td>";
                print "<td>".$row['JourneyDepartureTime']."</td>";
                print "<td>".$row['JourneyArrivalTime']."</td></tr></tbody>";
            }
            print "</table>";
		}
		else
		{
			print '<h3 class="text-info">You do not have any comfirmed bookings.</h3>';
		}
		
		?>
    </div>
</div>

</section>

<?php

include_once('includes/footer.html');

?>
