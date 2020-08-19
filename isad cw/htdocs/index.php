<?php

ini_set('display_errors',1);
ini_set('display_startup_errors',1);
error_reporting(E_ALL);

$page_title = "deadline and apponitment booking page";

require_once('database_classes/database.php');
include_once('includes/header.html');

?>

<section role="contentinfo" aria-label="Appointment and deadline app">
<div class="container">
    <div class="row">
        <h2 class="bg-dark text-white">deadline and appointment booking page</h2>
    </div>
    <div class="row">
        <p>in this page you will be able to book your appointment and confirm the deadline
        </p>
    </div>
    <div class="row">
        <p>APPOINTMENT</p>
        <?php
        $database = new Database();
        
        $rowSet = $database->vw_availableFlights();

        if($rowSet)
        {
            print "<table class=\"table table-bordered\">";
            print "<th scope='col'>Date</th>";
            print "<th scope='col'>Appointment start Time</th>";
            print "<th scope='col'>Available Seats</th>";
            print "<th scope='col'>appointment Price</th></tr></thead>";

            foreach ($rowSet as $row)
            {

                print "<td>".$row['JourneyDateFormatted']."</td>";
                print "<td>".$row['JourneyArrivalTime']."</td>";
                print "<td>".$row['JourneyPrice']."</td>";
                print "<td>".$row['JourneyAvailableSeats']."</td>";
                print '<td><a href="book.php?id='.$row['JourneyID'].'" class="btn btn-info">Book</a></td></tr></tbody>';
            }
            print "</table>";
        }

        ?>

    </div>

    <div class="row">
        <p>DEADLINES</p>
    <?php
    $database = new Database();

    $rowSet = $database->vw_airports();

    if($rowSet)
    {
        print "<table class=\"table table-bordered\">";
        print "<th scope='col'>Name</th>";
        print "<th scope='col'>child details</th>";
        print "<th scope='col'>actual grade</th>";
        print "<th scope='col'>grade intented</th>";

        foreach ($rowSet as $row)
        {

            print "<td>".$row['AirportName']."</td>";
            print "<td>".$row['AirportCountry']."</td>";
            print "<td>".$row['AirportLatitude']."</td>";
            print "<td>".$row['AirportLongitude']."</td></tr></tbody>";
            print '<td><a href="book.php?id='.$row['AirportLatitude'].'" class="btn btn-info">Book</a></td></tr></tbody>';
        }
        print "</table>";
    }

    ?>
</div>

</section>

<?php

include_once('includes/footer.html');

?>
