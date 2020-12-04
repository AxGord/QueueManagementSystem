<_include=all title="Электронная очередь - Для клиентов">

	<_Queue>

		<h2>Среднее время ожидания: %waittime%</h2>

		<h3>Пациенты перед вами</h3>

		<ul>
			<_many>
				<li>%reg% - %name%</li>
			</_many>
		</ul>

		<_insert auto>Запись на ближайшее время</_insert>

	</_Queue>

</_include>