<nav id="navigation" class="navbar navbar-default navbar-fixed-top" role="navigation" style="margin-bottom: 0">
    <div class="navbar-header">
        <!-- ############# Collapsable navigation menu #############-->
        <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
        </button>
        <a class="navbar-brand cursive" href="index.html">Holly Hotel</a>
    </div><!-- /.navbar-header -->
    <ul class="nav navbar-top-links navbar-right">
        <!-- /.dropdown -->
        <li class="dropdown">
            <a class="dropdown-toggle white" data-toggle="dropdown" href="#">
                <i class="fa fa-user fa-fw"></i> <?php echo($_SESSION['user_name']); ?> <i class="fa fa-caret-down"></i>
            </a>
            <ul class="dropdown-menu dropdown-user">
                <li><a href="#"><i class="fa fa-gear fa-fw"></i> Settings</a>
                </li>
                <li class="divider"></li>
                <li><a id="logout" href="logout.php" target="_self"><i class="fa fa-sign-out fa-fw"></i> Logout</a>
                </li>
            </ul>
            <!-- /.dropdown-user -->
        </li>
        <!-- /.dropdown -->
    </ul><!-- /.navbar-top-links -->
</nav>

<nav id="sidebar" class="navbar-default sidebar" role="navigation">
        <div class="sidebar-nav navbar-collapse">
            <ul class="nav" id="side-menu">
                <!-- Dashboard: Single -->
                <li><a href="/sandbox"><i class="fa fa-dashboard fa-fw"></i>&nbsp;Dashboard</a></li>
                <!-- Check In: Single -->
                <li><a href="/checkin"><i class="fa fa-check fa-fw"></i>&nbsp;Check In</a></li>
                <!-- Check Out: Single -->
                <li><a href="/checkout"><i class="fa fa-check-square-o fa-fw"></i>&nbsp;Check Out</a></li>
                <!-- Reservations Drop Down -->
                <li class="dropdown"><a href="#"><i class="fa fa fa-calendar-o fa-fw"></i>&nbsp;Reservations<span class="fa arrow"></span></a>
                    <ul class="nav nav-second-level">
                        <li><a href="/reservations">View All</a></li>
                        <li><a href="/reservations/new">New Reservation</a></li>
                        <li><a href="/reservations/today">Today</a></li>
                        <li><a href="/reservations/upcoming">Upcoming</a></li>
                    </ul>
                </li>
                <!-- Rooms Drop Down -->
                <li class="dropdown"><a href="#"><i class="fa fa-building fa-fw"></i>&nbsp;Rooms<span class="fa arrow"></span></a>
                    <ul class="nav nav-second-level">
                        <li><a href="/rooms">View All</a></li>
                        <li><a href="/rooms/available">Available</a></li>
                        <li><a href="/room/occupied">Occupied</a></li>
                        <li><a href="/room/maintenance">Maintenance</a></li>
                        <li class="dropdown"><a href="#"><i class="fa fa-building fa-fw"></i>Third Level Dropdown<span class="fa arrow"></span></a>
                            <ul class="nav nav-third-level">
                                <li><a href="/rooms">View All</a></li>
                                <li><a href="/rooms/avaible">Available</a></li>
                            </ul>
                        </li>
                    </ul>
                </li>
                <!-- Guests Drop Down-->
                <li class="dropdown"><a href="#"><i class="fa fa-users fa-fw"></i>&nbsp;Guests<span class="fa arrow"></span></a>
                    <ul class="nav nav-second-level">
                        <li><a href="/guests">Search</a></li>
                        <li><a href="/guests/new">Add New Guest</a></li>
                        <li><a href="/guests/current">Checked In</a></li>
                    </ul>
                </li>
                <!-- Maintanence Drop Down -->
                <li class="dropdown"><a href="#"><i class="fa fa fa-calendar-o fa-fw"></i>&nbsp;Maintenance<span class="fa arrow"></span></a>
                    <ul class="nav nav-second-level">
                        <li><a href="/maintanence">Open Requests</a></li>
                        <li><a href="/maintanence/urgent">Urgent</a></li>
                        <li><a href="/maintanence/history">Maintenance History</a></li>
                    </ul>
                </li>
            </ul>
        </div><!-- /.sidebar-collapse -->
</nav>