
/*Opción 1 - Se declara una variable, y se le asigna la información del JSON y por medio de la funcion OPENJSON de SQL
	se puede retornar la información en forma de filas y columnas*/
DECLARE @json NVARCHAR(MAX);
SET @json = N'[{
        "postcode": "0200",
        "country": "Australia",
        "countryabbreviation": "AU",
        "places": {
            "placename": "Australian National University",
            "longitude": "",
            "state": "Australian Capital Territory",
            "stateabbreviation": "ACT",
            "latitude": ""
        }

    }, {
        "postcode": "24000",
        "country": "Mexico",
        "countryabbreviation": "MX",
        "places": {
            "placename": "Ciudad Amurallada Centro",
            "longitude": "-90.7281",
            "state": "Campeche",
            "stateabbreviation": "CAM",
            "latitude": "18.6744"
        }

    }, {
        "postcode": "25000",
        "country": "Mexico",
        "countryabbreviation": "MX",
        "places": {
            "placename": "Saltillo Centro",
            "longitude": "-92.978",
            "state": "Coahuila De Zaragoza",
            "stateabbreviation": "CHP",
            "latitude": "16.2163"
        }

    }, {
        "postcode": "25001",
        "country": "Spain",
        "countryabbreviation": "ES",
        "places": {
            "placename": "Lleida",
            "longitude": "0.6419",
            "state": "Cataluna",
            "stateabbreviation": "CT",
            "latitude": "41.6109"
        }

    }, {
        "postcode": "01002",
        "country": "Spain",
        "countryabbreviation": "ES",
        "places": {
            "placename": "Vitoria-Gasteiz",
            "longitude": "-2.6667",
            "state": "Pais Vasco",
            "stateabbreviation": "PV",
            "latitude": "42.85"
        }

    }
]';

SELECT *
FROM OPENJSON(@json)
		WITH (
			post_code						nvarchar(max) '$.postcode',
			country							nvarchar(max) '$.country',
			country_abbreviation			nvarchar(max) '$.countryabbreviation',
			place_name						nvarchar(max) '$.places.placename',
			longitude						nvarchar(max) '$.places.longitude',
			[state]							nvarchar(max) '$.places.state',
			state_abbreviation				nvarchar(max) '$.places.stateabbreviation',
			latitude						nvarchar(max) '$.places.latitude'
		);
  


/*Opción 2 - Cuando un OBJETO contiene una lista de OBJETOS, se utiliza la función CROSS APPLY para
	realizar un recorrido sobre los elementos y poder extraer la información en filas y columnas según como corresponda.
	*/
 SELECT 
	'post_code'				=	objectJson.post_code
,	'country'				=	objectJson.country
,	'country_abbreviation'	=	objectJson.country_abbreviation
,	'places'				=	objectJson.places
,	'placename'				=	list_in_objects.placename
,	'longitude'				=	list_in_objects.longitude
,	'state'					=	list_in_objects.state
,	'stateabbreviation'		=	list_in_objects.stateabbreviation
,	'latitude'				=	list_in_objects.latitude
FROM OPENROWSET (BULK 'D:\Convertir_JSON_a_tabla_relacional_con_MsSql\Lista_de_objetos_JSON.json', SINGLE_CLOB) AS T
CROSS APPLY OPENJSON(BulkColumn)
	WITH (
		post_code				nvarchar(max) '$.postcode'
	,	country					nvarchar(max) '$.country'
	,	country_abbreviation	nvarchar(max) '$.countryabbreviation'
	,	places					nvarchar(max) AS JSON
	) AS objectJson
CROSS APPLY OPENJSON(objectJson.places)
	WITH (
		placename			nvarchar(max) '$.placename'
	,	longitude			nvarchar(max) '$.longitude'
	,	state				nvarchar(max) '$.state'
	,	stateabbreviation	nvarchar(max) '$.stateabbreviation'
	,	latitude			nvarchar(max) '$.latitude'
	) AS list_in_objects