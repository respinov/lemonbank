<?php
# Sample back end for a TrustDefender Mobile SDK enabled client. This is a very rough sample, and only demonstrates that
# the backend does the API query and generates content based on the results of the query
#
# In the real world, an existing customer back end would take care of this.

# This script runs 2 different API calls based on the request type, each type expects different arguments:
#   type 1: Strong authentication account registration or session query (if the device is already registered), expects
#           a) unique session id
#           b) username
#           c) password
#   type 2: Strong Authentication initiation expects:
#           a) session id - this must be the same session id as strong authentication registration
#           b) username   - this username must be the same as strong authentication registration

$api_server="h-api.online-metrix.net";
$org_id="";
$api_key="";
$service_type="session-policy";
$policy="strong_auth_reg_account_login";
$auth_init_policy="strong_auth_init_account_login";

$error=FALSE;
$api_fail=FALSE;
foreach($_REQUEST as $key => $val)
{
    switch($key)
    {
        case 'session_id':
            $session_id=urlencode($val);
            break;
        case 'username':
            $username=urlencode($val);
            break;
        case 'password':
            $password=urlencode(sha1($val));
            break;
        case 'type':
            $type=$val;
            break;
        default:
            $error=TRUE;
    }
}

# Breaking error conditions to make it easier to understand
# type should be sent in all requests
if(!isset($type))
{
    $error=TRUE;
}
if(!isset($session_id) || !isset($username))
{
    $error=TRUE;
}
?>
<html>
<head><title>Lemon Bank Sample Mobile App</title>
<link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <div id="page-wrap">
        <div id="inside">
<?php
if(!$error)
{
    # Specify the API Call URL
    switch($type)
    {
        case 1:
            # Auth register (user clicked on login)
            $api_url="https://$api_server/api/session-query?org_id=$org_id&api_key=$api_key&policy=$policy&session_id=$session_id&service_type=$service_type&account_login=$username&password_hash=$password&event_type=login";
            break;
        case 2:
            # Auth Init (user clicked on payment)
            $api_url="https://$api_server/api/session-query?service_type=$service_type&event_type=login&org_id=$org_id&api_key=$api_key&policy=$auth_init_policy&session_id=$session_id&account_login=$username";
            break;
        default:
            $error=TRUE;
    }

    # It is recommended to wait a small amount of time after login to execute the API call
    # This ensures the device has had time to complete the profiling process

    error_log($api_url);
    $api_results=file_get_contents($api_url);
    if($api_results === FALSE)
    {
        $api_fail=TRUE;
    }
    else
    {
        $results = parse_api($api_results);

        if($type==1)
        {
            # Display the top buttons
            print_buttons($results);

            # We would usually want to do something with the results here, and, of course, do some
            # authentication, perhaps more or less stringent depending on the results of the threatmetrix api request
            # However, we are just going to print the API results out to the client for demonstration purposes.

            # Print Welcome Info. This initial screen displays a categorized sub-set of the profiling attributes.
            print_welcome($results);

            # And, for completeness we will dump out the remaining results. This can be activated by clicking the 'More Info' button on the client.
            # The more info button uses the lemonbank.js to switch between displaying the welcome content and the full profiling content.
            print_session_results($results);
        }
        else if($type==2)
        {
            do_strong_auth_logic($results);
        }
    }
}
if($api_fail || $error)
{
    echo "<h1>Error! Unable to retrieve request data</h1>\n";
    if($error)
    {
        echo '<h3>Invalid arguments</h3>';
    }
    else
    {
        echo '<h3>API request failure</h3>';
    }
}

function print_label($desc, $value)
{
    if(isset($value))
    {
        if(is_array($value))
        {
            $value = implode(",", $value);
        }
        echo "<div class=\"result_line\"><span class=\"label\">$desc: </span><span class=\"result\">$value</span></div>\n";
    }
    else
    {
        echo "<div class=\"result_line\"><span class=\"label\">$desc: </span><span class=\"result_unknown\">Unknown</span></div>\n";
    }
}

function print_buttons($api)
{
    $body = '';
    foreach($api as $key => $value)
    {
        if(is_array($value))
        {
            $value = implode(",", $value);
        }
        $body .= "$key: $value\n";
    }
    $body = rawurlencode(str_replace('&', ' and ', $body));

    $subject = "LemonBank Session Query Results";
    $subject = rawurlencode($subject);

    echo "<div id=\"header\">\n
    <input name=\"btnEmail\" id=\"btnEmail\" class=\"btnLemonGradient\" type=\"button\" value=\"Email\" onClick=\"window.location = 'mailto:%20?subject=$subject&body=$body'\"/>\n
    <input name=\"btnMoreInfo\" id=\"btnMoreInfo\" class=\"btnLemonGradient\" type=\"button\" value=\"More Info\"/>\n
    <input name=\"btnLessInfo\" id=\"btnLessInfo\" class=\"btnLemonGradient\" type=\"button\" value=\"Less Info\"/>\n
    </div>";
}

function print_welcome($api)
{
    # Print out the attributes to the client

    # -------- START USER INFO ---------
    $user_array = array(
                        'Account Login'       => 'account_login',
                        'Account First Seen'  => 'account_login_first_seen',
                        'Account Last Login'  => 'account_login_last_event',
                        );

    # This main-content DIV is the parent container
    echo "<div id=\"main-content\">\n";

    # Insert DIV
    echo "<div id=\"userInfo\" class=\"infoDIV\"><span class=\"heading\">User Information</span>\n";

    foreach($user_array as $desc => $attribute)
    {
        $value = isset($api[$attribute]) ? $api[$attribute] : NULL;
        print_label($desc, $value);
    }

    echo "</div>\n";
    # -------- END USER INFO ---------

    # -------- START DEVICE INFO ---------
    $device_array = array(
                          'Exact ID'            => 'device_id',
                          'Device First Seen'   => 'device_first_seen',
                          'Device Last Seen'    => 'device_last_event',
                          'Device Model'        => 'agent_model',
                          'OS'                  => 'agent_os',
                          'OS Version'          => 'agent_os_version',
                          'Screen Resolution'   => 'screen_res',
                          'JB / Root'           => 'jb_root',
                          );

    # Insert DIV
    echo "<div id=\"deviceInfo\" class=\"infoDIV\"><span class=\"heading\">Device Information</span>\n";

    foreach($device_array as $desc => $attribute)
    {
        $value = isset($api[$attribute]) ? $api[$attribute] : NULL;
        print_label($desc, $value);
    }

    echo "</div>\n";
    # -------- END USER INFO ---------

    # -------- START LOCATION INFO ---------
    $location_array = array(
                            'True IP Address'            => 'true_ip',
                            'True IP Country'            => 'true_ip_geo',
                            'True IP City'               => 'true_ip_city',
                            'Hardware Latitude'          => 'hw_latitude',
                            'Hardware Longitude'         => 'hw_longitude',
                            'GPS Accuracy (Meters)'      => 'hw_gps_accuracy',
                            'Distance IP / GPS (Meters)' => 'custom_count_1',
                            );

    # Open LOCATION DIV
    echo "<div id=\"locationInfo\" class=\"infoDIV\"><span class=\"heading\">Network & Location Information</span>\n";

    foreach($location_array as $desc => $attribute)
    {
        $value = isset($api[$attribute]) ? $api[$attribute] : NULL;
        print_label($desc, $value);
    }

    echo "</div>\n";
    # -------- END LOCATION INFO ---------

    # -------- START APP REP INFO ---------
    $app_array = array(
                       'Running Apps'   => 'apprep_runningapps',
                       'Installed Apps' => 'apprep_installedapps',
                       );

    # Insert DIV
    echo "<div id=\"appInfo\" class=\"infoDIV\"><span class=\"heading\">App Information</span>\n";

    foreach($app_array as $desc => $attribute)
    {
        $value = isset($api[$attribute]) ? $api[$attribute] : NULL;
        print_label($desc, $value);
    }

    echo "</div>\n";
    # -------- END POLICY INFO ---------

    # -------- START POLICY INFO ---------
    $policy_array = array(
                          'Policy Score'  => 'policy_score',
                          'Reason Codes'  => 'reason_code',
                          );

    # Insert DIV
    echo "<div id=\"policyInfo\" class=\"infoDIV\"><span class=\"heading\">Policy Information</span>\n";

    foreach($policy_array as $desc => $attribute)
    {
        $value = isset($api[$attribute]) ? $api[$attribute] : NULL;
        print_label($desc, $value);
    }

    echo "</div>\n";
    # -------- END POLICY INFO ---------

    #Close the welcome DIV
    echo "</div>\n";
}

function print_session_results($api)
{
    # Print out all the API key value pairs
    #Open the main-content2 DIV
    echo "<div id=\"main-content2\" class=\"infoDIV\"><span class=\"heading\">Full Session Query Output</span>\n";
    #

    foreach($api as $key => $value)
    {
        print_label($key, $value);
    }
    #Close the main-content2 DIV
    echo "</div>\n";
}

function print_strong_auth($results)
{
    #Print information related to StrongAuthentication
    # -------- START AUTH INFO ---------
    $auth_array = array(
                        'Authentication Method'      => 'auth_methods',
                        'Authentication Status'      => 'auth_status',
                        'Authentication Signature'   => 'strong_auth_signature',
                        'Authentication Certificate' => 'strong_auth_certificate',
                        );

    # This main-content DIV is the parent container
    echo "<div id=\"main-content\">\n";

    # Insert DIV
    echo "<div id=\"authInfo\" class=\"infoDIV\"><span class=\"heading\">Authentication Info</span>\n";

    foreach($auth_array as $desc => $attribute)
    {
        $value = isset($results[$attribute]) ? $results[$attribute] : NULL;
        print_label($desc, $value);
    }

    echo "</div>\n";
    # -------- END AUTH INFO ---------

    #Close the welcome DIV
    echo "</div>\n";
}

function print_error($results, $extra)
{
    echo "<h1 class=\"label\">Error! Payment failed</h1>\n";
    echo "<h3 class=\"label\">Strong Authentication API request failure</h3>";
    echo $extra;
    # -------- START AUTH INFO ---------
    $auth_array = array(
                        'Authentication method' => 'auth_methods',
                        'Authentication Status' => 'auth_status',
                        'Request ID'            => 'request_id',
                        'Request Result'        => 'request_result',
                        );

    # This main-content DIV is the parent container
    echo "<div id=\"main-content\">\n";

    # Insert DIV
    echo "<div id=\"authInfo\" class=\"infoDIV\"><span class=\"heading\">Payment Failed</span>\n";

    foreach($auth_array as $desc => $attribute)
    {
        $value = isset($results[$attribute]) ? $results[$attribute] : NULL;
        print_label($desc, $value);
    }

    echo "</div>\n";
    # -------- END AUTH INFO ---------

    #Close the error DIV
    echo "</div>\n";
}

function do_strong_auth_logic($api)
{
    if($api["auth_status"]!= "auth_init")
    {
        # Auth init failed can't proceed
        print_buttons($api);
        print_error($api, "");
        print_session_results($api);
        return;
    }

    //auth_devices = [{"device_nickname": "iPhone 6s","device_model":"iPhone 6s","device_os":"iOS","auth_methods": ["tmxdevicepresence"],"registration_timestamp": "2018-03-05 22:08:26","device_id": "1a9296365e608e5d2bb01777dfb7589081c3af0a","authenticator_id": "1a9296365e608e5d2bb01777dfb7589081c3af0a"}, {<Another one>}]
    $device_name=$api["device_name"];
    $latest_reg=mktime(0, 0, 0, 1, 1, 1970); //generate unix timestamp of zero, it is more readable to use a date here than a simple 0
    $auth_devices=$api["auth_devices"];
    $json=json_decode($auth_devices, true);

    foreach($json as $auth_dev)
    {
        $device_nickname=$auth_dev["device_nickname"];
        if($device_nickname==$device_name)
        {
            //found one registration with same device name, check the registration date in case it's registered more than once
            $reg_date=strtotime($auth_dev["registration_timestamp"]);
            if($reg_date >= $latest_reg)
            {
                $device_id=$auth_dev["authenticator_id"];
                $latest_reg=$reg_date;
            }
        }
    }

    $request_id=$api["request_id"];
    $prompt=urlencode("Confirmation is required for payment");
    $title=urlencode("Please confirm");
    global $api_key, $org_id, $api_server, $service_type;

    # Authentication
    $authenticate_url="https://$api_server/authentication/authenticate?auth_methods=tmxdevicepresence&service_type=$service_type&org_id=$org_id&api_key=$api_key&request_id=$request_id&auth_device_id=$device_id&display_message=$prompt&display_title=$title";

    $authenticate=file_get_contents($authenticate_url);
    $auth_result=parse_api($authenticate);
    if($authenticate == FALSE || $auth_result["auth_status"] != "auth_in_progress")
    {
        # authentication API failed can't proceed
        print_buttons($auth_result);
        print_error($auth_result, "");
        print_session_results($auth_result);
        return;
    }

    # authentication was sent wait for some seconds before polling the result
    sleep(5);

    # Getting the final result of strong authentication, since authentication happens on the client side
    # we poll the result and for 30 seconds
    for($i = 0; $i < 30; $i++)
    {
        if(poll_auth_result($request_id) == TRUE)
        {
            return;
        }
        # authentication is not finished on client side yet, wait one second and try again
        sleep(1);
    }

    # polling wasn't return after 30 seconds, print what we have
    # maybe we need more time
    $extra="<div class=\"result\">Polling timed out after 30 seconds, please consider using a longer timeout </div>";
    print_buttons($auth_result);
    print_error($auth_result, $extra);
    print_session_results($auth_result);
}

function poll_auth_result($request_id)
{
    global $api_key, $org_id, $api_server, $service_type;
    # Poll Auth result
    $poll_url="https://$api_server/authentication/query_authentication_result?org_id=$org_id&api_key=$api_key&request_id=$request_id&service_type=$service_type&event_type=login";
    $poll=file_get_contents($poll_url);
    $auth_result=parse_api($poll);
    if($auth_result["auth_status"] == "auth_in_progress")
    {
        return FALSE;
    }
    else
    {
        # Print the final result of strong authentication
        print_buttons($auth_result);
        print_strong_auth($auth_result);
        print_session_results($auth_result);
        return TRUE;
    }
}

function parse_api($api_result)
{
    # api results are a & seperated key/(url encoded) value pair list, like a URL parameter list
    # we want to parse them into an associative array for ease of access
    $kvs = explode("&", $api_result);

    $results = array();

    foreach($kvs as $string)
    {
        $kv = explode("=", $string);

        if(isset($kv[0]) && isset($kv[1]))
        {
            $value = urldecode($kv[1]);
            if(isset($results[$kv[0]]))
            {
                # An entry already exists, so lets make an array of the values
                if(!is_array($results[$kv[0]]))
                {
                    $results[$kv[0]] = array($results[$kv[0]]);
                }
                array_push($results[$kv[0]], $value);
            }
            else
            {
                $results[$kv[0]] = $value;
            }
        }
    }

    return $results;
}

?>
<script src="lemonbank.js"></script>
        </div>
    </div>
</body>
</html>

