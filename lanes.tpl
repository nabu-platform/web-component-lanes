<template id="data-lanes-configurator">
	<data-common-configure :page="page" :parameters="parameters" :cell="cell"
			:edit="edit"
			:records="records"
			:selected="selected"
			:inactive="inactive"
			@updatedEvents="$emit('updatedEvents')"
			@close="$emit('close'); configuring=false"
			:multiselect="true"
			:configuring="true"
			:updatable="true"
			:paging="paging"
			:filters="filters"
			@refresh="refresh">

		<div slot="settings">
			<n-collapsible title="Lane Settings">
				<div class="padded-content">
					<n-form-combo v-model="cell.state.stateField" :items="keys" label="State field" info="The field that contains the current state of the record"/>
				</div>
				<div v-if="cell.state.lanes">
					<n-collapsible v-for="lane in cell.state.lanes" :title="lane.name ? lane.name : 'Unnamed'" class="padded">
						<n-form-text v-model="lane.name" :timeout="600" label="Name"/>
						<n-form-text v-model="lane.label" :timeout="600" label="Label"/>
						<div v-for="state in lane.states" class="list-row">
							<n-form-text v-model="state.label" :timeout="600" label="Label"/>
							<n-form-text v-model="state.value" :timeout="600" label="Value"/>
							<n-form-text v-model="state.class" :timeout="600" label="Class"/>
						</div>
						<div class="list-actions">
							<button @click="lane.states.push({})"><span class="fa fa-plus"></span>State</button>
						</div>
					</n-collapsible>
				</div>
				<div class="list-actions">
					<button @click="addLane"><span class="fa fa-plus"></span>Lane</button>
				</div>
			</n-collapsible>
		</div>
	</data-common-configure>
</template>

<template id="data-lanes">
	<div class="data-lanes" :class="{'dragging': dragging}">
		<data-common-header :page="page" :parameters="parameters" :cell="cell"
				:edit="edit"
				:records="records"
				:selected="selected"
				:inactive="inactive"
				@updatedEvents="$emit('updatedEvents')"
				@close="$emit('close'); configuring=false"
				:multiselect="true"
				:configuring="configuring"
				:updatable="true"
				:paging="paging"
				:filters="filters"
				@refresh="refresh">
			</n-collapsible>
		</data-common-header>
		
		<div class="data-lane-list" v-if="cell.state.lanes" @dragend="stopDrag($event)">
			<div v-for="lane in cell.state.lanes" class="data-lane" :class="lane.class">
				<label class="data-lane-label" v-if="lane.label">{{$services.page.translate($services.page.interpret(lane.label, $self))}}</label>
				<div v-for="state in lane.states" class="data-lane-state" :class="[state.class, {'droppable': dragging && acceptRecord(null, state)}]"
						@dragend="stopDrag($event)">
					<label class="data-lane-state-label" v-if="state.label">{{$services.page.translate($services.page.interpret(state.label, $self))}}</label>

					<div class="data-lane-cards" >
						<dl class="data-lane-card" @click="select(record, false, $event)" v-for="record in getRecordsInState(state)" :class="getRecordClasses(record)" :key="getKey(record)"
								:draggable="true"
								@dragstart="dragRecord($event, state, record)">
							<page-field :field="field" :data="record" :should-style="false" 
								:edit="edit"
								class="data-card-field" :class="$services.page.getDynamicClasses(field.styles, {record:record}, $self)" v-for="field in cell.state.fields"
								v-if="!isFieldHidden(field, record)"
								:label="cell.state.showLabels"
								:actions="fieldActions(field)"
								@updated="update(record)"
								:page="page"
								:cell="cell"/>
							<div class="data-card-actions" v-if="actions.length" @mouseover="actionHovering = true" @mouseout="actionHovering = false">
								<button v-if="!action.condition || $services.page.isCondition(action.condition, {record:record}, $self)" 
									v-for="action in recordActions" 
									@click="trigger(action, record)"
									:class="[action.class, {'has-icon': action.icon}]"><span v-if="action.icon" class="fa" :class="action.icon"></span><label v-if="action.label">{{$services.page.translate(action.label)}}</label></button>
							</div>
						</dl>
					</div>
					<div class="data-lane-state-dropzone"
							@dragover="acceptRecord($event, state)"
							@drop="dropRecord($event, state)"
							@dragend="stopDrag($event)">
						<span class="data-lane-state-dropzone-description">Drop your items here</span>
					</div>
				</div>
			</div>
		</div>

		<n-paging :value="paging.current" :total="paging.total" :load="load" :initialize="false" v-if="!cell.state.loadLazy && !cell.state.loadMore"/>
		<div class="load-more" v-else-if="cell.state.loadMore && paging.current != null && paging.total != null && paging.current < paging.total - 1">
			<button class="load-more-button" @click="load(paging.current + 1, true)">%{Load More}</button>
		</div>
		
		<data-common-footer :page="page" :parameters="parameters" :cell="cell" 
			:edit="edit"
			:records="records"
			:selected="selected"
			:inactive="inactive"
			:global-actions="globalActions"
			@updatedEvents="$emit('updatedEvents')"
			@close="$emit('close')"
			:multiselect="true"
			:updatable="true"/>
	</div>
</template>