<?php
class eZSurveyGeo extends eZSurveyQuestion
{

	const LAT_LON_DELIM = '|';

	/*
	Question Type: Geo

	Data Storage: 
		answer - lat;lon
	*/

	/*
	* constructor
	*/
	function eZSurveyGeo( $row = false )
	{
		$bfsf_ini = eZINI::instance('bfsurveygeo.ini');

		$survey_object_id = 0;

		//get survey object (lookup object ID, as the survey_id changes with each edit)
		$survey = new eZSurveyType();
		$surveyObject = $survey->fetchSurveyByID( $row['survey_id'] );
		if($surveyObject) { $survey_object_id = $surveyObject->attribute('contentobject_id'); }

		$row[ 'type' ] = 'Geo';
		if ( !isset( $row['mandatory'] ) ) $row['mandatory'] = 0; {
			$this->eZSurveyQuestion( $row );
		}
	}

    /*
     * called when a question is created / edited in the admin
     * In this case we only have to save the question text and the mandatory checkbox value
     */
	function processEditActions( &$validation, $params )
	{

		$http = eZHTTPTool::instance();
		$prefix = eZSurveyType::PREFIX_ATTRIBUTE;
		$attributeID = $params[ 'contentobjectattribute_id' ];

		//title of the question
		$postQuestionText = $prefix . '_ezsurvey_question_' . $this->ID . '_text_' . $attributeID;
		if( $http->hasPostVariable( $postQuestionText ) and $http->postVariable( $postQuestionText ) != $this->Text )
		{
			$this->setAttribute( 'text', $http->postVariable( $postQuestionText ) );
		}

		$postQuestionMandatoryHidden = $prefix . '_ezsurvey_question_' . $this->ID . '_mandatory_hidden_' . $attributeID;
		if( $http->hasPostVariable( $postQuestionMandatoryHidden ) )
		{
			$postQuestionMandatory = $prefix . '_ezsurvey_question_' . $this->ID . '_mandatory_' . $attributeID;
			if( $http->hasPostVariable( $postQuestionMandatory ) )
				$newMandatory = 1;
			else
				$newMandatory = 0;

			if( $newMandatory != $this->Mandatory )
			$this->setAttribute( 'mandatory', $newMandatory );
		}
	}
 
   /*
     * Checks input
     */
	function processViewActions( &$validation, $params )
	{

		$http = eZHTTPTool::instance();
		$variableArray = array();

		$prefix = eZSurveyType::PREFIX_ATTRIBUTE;
		$answerValue = '';
		$surveyAnswer = '';

		//Option 1) look for already saved value
		$postSurveyAnswer = $prefix . '_ezsurvey_answer_' . $this->ID . '_' . $this->contentObjectAttributeID();
		$postSurveyLat = $prefix . '_ezsurvey_latitude_' . $this->ID . '_' . $this->contentObjectAttributeID();
		$postSurveyLon = $prefix . '_ezsurvey_longitude_' . $this->ID . '_' . $this->contentObjectAttributeID();

		if ( $http->hasPostVariable( $postSurveyAnswer ) )
		{
			if( count($surveyAnswer) > 0 ) {
				$surveyAnswer = $http->postVariable( $postSurveyAnswer );
				$this->setAnswer( $surveyAnswer );
			}
		}
		
		if( isset( $_POST[$postSurveyLat]) && isset( $_POST[$postSurveyLon]) ) {
			if( !empty($_POST[$postSurveyLat]) && !empty($_POST[$postSurveyLon])) {
				$saveAttempt = true;
			}
		}

		if ( $this->attribute( 'mandatory' ) == 1 ) {
			if( !$saveAttempt && !$surveyAnswer ) {
				$validation['error'] = true;
				$validation['errors'][] = array( 'message' => ezpI18n::tr( 'survey', 'Please re-enter the geo value', null,
				array( '%number' => $this->questionNumber() ) ),
				'question_number' => $this->questionNumber(),
				'code' => 'general_answer_number_as_well',
				'question' => $this );
				return false;
			}
		}

		//can return blank
		$variableArray[ 'answer' ] = $surveyAnswer;
		return $variableArray;
	}

    //This is called during the processViewActions chain and storeResult();    
    function answer()
    {
		//option 1) check for already defined
		if ( strlen($this->Answer) ) {
			return $this->Answer;
		}

		$http = eZHTTPTool::instance();
		$prefix = eZSurveyType::PREFIX_ATTRIBUTE;

		//option 2) check for input post
		$postSurveyLat = $prefix . '_ezsurvey_latitude_' . $this->ID . '_' . $this->contentObjectAttributeID();
		$postSurveyLon = $prefix . '_ezsurvey_longitude_' . $this->ID . '_' . $this->contentObjectAttributeID();

		if( isset( $_POST[$postSurveyLat]) && isset( $_POST[$postSurveyLon]) ) {
			if( !empty($_POST[$postSurveyLat]) && !empty($_POST[$postSurveyLon])) {
				$latitude = $_POST[$postSurveyLat];
				$longitude = $_POST[$postSurveyLon];
				
				$surveyAnswer = $latitude.self::LAT_LON_DELIM.$longitude; //syntax "lat;lon"

				$this->setAnswer($surveyAnswer);
				return $surveyAnswer;
			}
		}

		//option 3) check for answer post
		$postSurveyAnswer = $prefix . '_ezsurvey_answer_' . $this->ID . '_' . $this->contentObjectAttributeID();
		if ( $http->hasPostVariable( $postSurveyAnswer ) && strlen($http->postVariable( $postSurveyAnswer ) ) )
		{
			$surveyAnswer = $http->postVariable( $postSurveyAnswer );
			return $surveyAnswer;
		}    

		return $this->Default;
	}

}
eZSurveyQuestion::registerQuestionType( ezpI18n::tr( 'survey', 'Geo' ), 'Geo' );
?>